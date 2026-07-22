import { createHash } from "node:crypto"
import { execFile } from "node:child_process"
import { mkdir, realpath, stat } from "node:fs/promises"
import { homedir } from "node:os"
import { basename, dirname, resolve } from "node:path"
import { promisify } from "node:util"
import { tool, type Plugin } from "@opencode-ai/plugin"

const execFileAsync = promisify(execFile)

type Repository = {
  root: string
  identity: string
  branch: string | null
  commit: string
  dirty: boolean
}

type Worktree = {
  path: string
  commit: string
  branch: string | null
}

type Tuple = {
  repositoryRoot: string
  repositoryIdentity: string
  branch: string
  path: string
  base: string
  baseCommit: string
}

const git = async (args: string[], cwd: string) => {
  const result = await execFileAsync("git", args, {
    cwd,
    maxBuffer: 1024 * 1024,
  })

  return result.stdout.trim()
}

const succeeds = async (args: string[], cwd: string) => {
  try {
    await git(args, cwd)
    return true
  } catch {
    return false
  }
}

const normalizeSlug = (value: string, label: string) => {
  const slug = value
    .normalize("NFKD")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60)
    .replace(/-+$/g, "")

  if (!slug) throw new Error(`${label} must contain at least one ASCII letter or digit`)
  return slug
}

const hash = (value: string) => createHash("sha256").update(value).digest("hex")

const identityFor = (root: string) => hash(root)

const fingerprintFor = (tuple: Tuple) =>
  hash(
    JSON.stringify({
      base: tuple.base,
      baseCommit: tuple.baseCommit,
      branch: tuple.branch,
      path: tuple.path,
      repositoryIdentity: tuple.repositoryIdentity,
      repositoryRoot: tuple.repositoryRoot,
    }),
  )

const quote = (value: string) => `'${value.replaceAll("'", "'\\''")}'`

const parseWorktrees = (output: string): Worktree[] => {
  const worktrees: Worktree[] = []
  let current: Partial<Worktree> = {}

  const append = () => {
    if (current.path && current.commit) {
      worktrees.push({
        path: current.path,
        commit: current.commit,
        branch: current.branch ?? null,
      })
    }
    current = {}
  }

  for (const line of output.split("\n")) {
    if (line === "") {
      append()
    } else if (line.startsWith("worktree ")) {
      current.path = line.slice("worktree ".length)
    } else if (line.startsWith("HEAD ")) {
      current.commit = line.slice("HEAD ".length)
    } else if (line.startsWith("branch refs/heads/")) {
      current.branch = line.slice("branch refs/heads/".length)
    }
  }
  append()

  return worktrees
}

const worktreesFor = async (root: string) =>
  parseWorktrees(await git(["worktree", "list", "--porcelain"], root))

const repositoryFor = async (cwd: string): Promise<Repository> => {
  const topLevel = await realpath(await git(["rev-parse", "--show-toplevel"], cwd))
  const commonDirectory = resolve(
    topLevel,
    await git(["rev-parse", "--git-common-dir"], cwd),
  )
  const primaryRoot = await realpath(
    basename(commonDirectory) === ".git" ? dirname(commonDirectory) : topLevel,
  )
  const branch = await git(["symbolic-ref", "--quiet", "--short", "HEAD"], cwd).catch(
    () => null,
  )
  const status = await git(["status", "--porcelain", "--untracked-files=all"], cwd)

  return {
    root: primaryRoot,
    identity: identityFor(primaryRoot),
    branch,
    commit: await git(["rev-parse", "HEAD"], cwd),
    dirty: status !== "",
  }
}

const rootFromEnvironment = () =>
  resolve(process.env.OPENCODE_WORKTREE_ROOT ?? joinDefaultWorktreeRoot())

const joinDefaultWorktreeRoot = () =>
  `${homedir()}/.local/share/opencode/worktrees`

const tupleFor = async (
  cwd: string,
  feature: string,
  base: string,
  worktreeRoot = rootFromEnvironment(),
): Promise<Tuple & { repository: Repository; command: string; fingerprint: string }> => {
  const repository = await repositoryFor(cwd)
  const slug = normalizeSlug(feature, "feature")
  const repositoryName = normalizeSlug(basename(repository.root), "repository")
  const root = resolve(worktreeRoot)
  const path = resolve(root, repositoryName, slug)
  const branch = `feature/${slug}`
  const baseCommit = await git(["rev-parse", "--verify", `${base}^{commit}`], repository.root)
  const tuple = {
    repositoryRoot: repository.root,
    repositoryIdentity: repository.identity,
    branch,
    path,
    base,
    baseCommit,
  }

  return {
    ...tuple,
    repository,
    fingerprint: fingerprintFor(tuple),
    command: [
      "git",
      "worktree",
      "add",
      "-b",
      quote(branch),
      quote(path),
      quote(base),
    ].join(" "),
  }
}

const collisionReport = async (tuple: Tuple, worktrees: Worktree[]) => {
  const registered = worktrees.find((worktree) => resolve(worktree.path) === tuple.path)
  const branchExists = await succeeds(
    ["show-ref", "--verify", `refs/heads/${tuple.branch}`],
    tuple.repositoryRoot,
  )
  let pathExists = false
  let pathRepository: Repository | null = null

  try {
    await stat(tuple.path)
    pathExists = true
    pathRepository = await repositoryFor(tuple.path)
  } catch {
    // The target path is available or is not a Git repository.
  }

  const exactMatch =
    registered?.branch === tuple.branch &&
    pathRepository?.root === tuple.repositoryRoot &&
    pathRepository.identity === tuple.repositoryIdentity

  return {
    branchExists,
    exactMatch,
    pathExists,
    pathRepository: pathRepository
      ? {
          branch: pathRepository.branch,
          identity: pathRepository.identity,
          root: pathRepository.root,
        }
      : null,
    registered,
  }
}

const validateTuple = async (cwd: string, tuple: Tuple, fingerprint: string) => {
  const current = await repositoryFor(cwd)
  if (current.root !== tuple.repositoryRoot || current.identity !== tuple.repositoryIdentity) {
    throw new Error("repository identity changed since preview")
  }

  const resolvedBase = await git(
    ["rev-parse", "--verify", `${tuple.base}^{commit}`],
    current.root,
  )
  if (resolvedBase !== tuple.baseCommit) throw new Error("base ref changed since preview")
  if (fingerprintFor(tuple) !== fingerprint) throw new Error("approval fingerprint does not match tuple")

  return current
}

export const FeatureWorktreePlugin: Plugin = async ({ worktree }) => {
  const preview = tool({
    description: "Preview a deterministic feature worktree and report collisions.",
    args: {
      feature: tool.schema.string(),
      base: tool.schema.string(),
      worktreeRoot: tool.schema.string().optional(),
    },
    async execute({ feature, base, worktreeRoot }) {
      const result = await tupleFor(worktree, feature, base, worktreeRoot)
      const collisions = await collisionReport(result, await worktreesFor(result.repositoryRoot))

      return JSON.stringify(
        {
          branch: result.branch,
          base: result.base,
          baseCommit: result.baseCommit,
          command: result.command,
          collisions,
          dirty: result.repository.dirty,
          fingerprint: result.fingerprint,
          path: result.path,
          repositoryIdentity: result.repositoryIdentity,
          repositoryRoot: result.repositoryRoot,
        },
        null,
        2,
      )
    },
  })

  const create = tool({
    description: "Create the exact feature worktree tuple approved by the user.",
    args: {
      repositoryRoot: tool.schema.string(),
      repositoryIdentity: tool.schema.string(),
      branch: tool.schema.string(),
      path: tool.schema.string(),
      base: tool.schema.string(),
      baseCommit: tool.schema.string(),
      fingerprint: tool.schema.string(),
    },
    async execute(tuple) {
      const current = await validateTuple(worktree, tuple, tuple.fingerprint)
      const collisions = await collisionReport(tuple, await worktreesFor(current.root))

      if (collisions.exactMatch) return "Exact feature worktree already exists; reusing it."
      if (collisions.branchExists || collisions.pathExists || collisions.registered) {
        throw new Error(`feature worktree collision: ${JSON.stringify(collisions)}`)
      }

      await mkdir(dirname(tuple.path), { recursive: true })
      await git(["worktree", "add", "-b", tuple.branch, tuple.path, tuple.base], current.root)

      const created = await repositoryFor(tuple.path)
      if (created.root !== tuple.repositoryRoot || created.branch !== tuple.branch) {
        throw new Error("created worktree failed post-create identity verification")
      }

      return `Created ${tuple.branch} at ${tuple.path}`
    },
  })

  const status = tool({
    description: "Inspect linked worktrees for the current canonical repository.",
    args: {},
    async execute() {
      const repository = await repositoryFor(worktree)
      return JSON.stringify(
        {
          current: repository,
          worktrees: await worktreesFor(repository.root),
        },
        null,
        2,
      )
    },
  })

  const cleanup = tool({
    description: "Remove a clean feature worktree after explicit approval.",
    args: {
      repositoryRoot: tool.schema.string(),
      repositoryIdentity: tool.schema.string(),
      branch: tool.schema.string(),
      path: tool.schema.string(),
      base: tool.schema.string(),
      baseCommit: tool.schema.string(),
      fingerprint: tool.schema.string(),
      allowUnmergedRemoval: tool.schema.boolean(),
    },
    async execute(tuple) {
      const current = await validateTuple(worktree, tuple, tuple.fingerprint)
      const target = await repositoryFor(tuple.path)
      if (
        target.root !== tuple.repositoryRoot ||
        target.identity !== tuple.repositoryIdentity ||
        target.branch !== tuple.branch
      ) {
        throw new Error("target worktree identity does not match the approved tuple")
      }
      if (target.dirty) throw new Error("refusing to remove a dirty worktree")

      const merged = await succeeds(
        ["merge-base", "--is-ancestor", tuple.branch, tuple.base],
        current.root,
      )
      if (!merged && !tuple.allowUnmergedRemoval) {
        throw new Error("refusing to remove an unmerged worktree without explicit approval")
      }

      await git(["worktree", "remove", tuple.path], current.root)
      return `Removed ${tuple.path}`
    },
  })

  return {
    tool: {
      feature_worktree_preview: preview,
      feature_worktree_create: create,
      feature_worktree_status: status,
      feature_worktree_cleanup: cleanup,
    },
  }
}
