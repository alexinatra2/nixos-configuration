import { createHash, randomUUID } from "node:crypto"
import { execFile } from "node:child_process"
import { mkdir, realpath, stat } from "node:fs/promises"
import { homedir } from "node:os"
import { basename, dirname, resolve } from "node:path"
import { promisify } from "node:util"
import { tool, type Plugin, type ToolContext } from "@opencode-ai/plugin"

const execFileAsync = promisify(execFile)
const lifecycleVersion = "2"

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

type Feature = {
  slug: string
  branch: string
  base: string
  path: string
  repository: Repository
}

type Lifecycle = {
  version: string
  id: string
  repository: string
  branch: string
  base: string
  path: string
  acceptedHead: string
  reviewCommit: string | null
  reviewReady: boolean
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
  const input = value.startsWith("feature/") ? value.slice("feature/".length) : value
  const slug = input
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
  const primary = parseWorktrees(await git(["worktree", "list", "--porcelain"], cwd))[0]
  if (!primary) throw new Error("repository has no primary worktree")
  const primaryRoot = await realpath(primary.path)
  const branch = await git(["symbolic-ref", "--quiet", "--short", "HEAD"], cwd).catch(
    () => null,
  )
  const status = await git(["status", "--porcelain", "--untracked-files=all"], cwd)

  return {
    root: primaryRoot,
    identity: hash(primaryRoot),
    branch,
    commit: await git(["rev-parse", "HEAD"], cwd),
    dirty: status !== "",
  }
}

const defaultWorktreeRoot = () =>
  resolve(process.env.OPENCODE_WORKTREE_ROOT ?? `${homedir()}/.local/share/opencode/worktrees`)

const defaultBase = async (repository: Repository) => {
  const remoteHead = await git(
    ["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"],
    repository.root,
  ).catch(() => null)
  const candidate = remoteHead?.replace(/^origin\//, "") ?? repository.branch
  if (!candidate) throw new Error("base branch is required for a detached repository")
  return candidate
}

const featureFor = async (
  cwd: string,
  feature: string,
  base?: string,
): Promise<Feature> => {
  const repository = await repositoryFor(cwd)
  const slug = normalizeSlug(feature, "feature")
  const repositoryName = normalizeSlug(basename(repository.root), "repository")
  const selectedBase = base ?? (await defaultBase(repository))
  const configuredRoot = defaultWorktreeRoot()
  const worktreeRoot = await realpath(configuredRoot).catch(() => configuredRoot)
  if (
    !(await succeeds(
      ["show-ref", "--verify", `refs/heads/${selectedBase}`],
      repository.root,
    ))
  ) {
    throw new Error(`blocked base=${selectedBase} reason=base-not-local-branch`)
  }

  return {
    slug,
    branch: `feature/${slug}`,
    base: selectedBase,
    path: resolve(worktreeRoot, repositoryName, slug),
    repository,
  }
}

const configKey = (branch: string) => `branch.${branch}.opencode-lifecycle`

const lifecycleData = (feature: Feature, id: string, acceptedHead: string) => ({
  version: lifecycleVersion,
  id,
  repository: feature.repository.identity,
  branch: feature.branch,
  base: feature.base,
  path: feature.path,
  acceptedHead,
  reviewCommit: null,
  reviewReady: false,
})

const lifecycleFor = async (feature: Feature): Promise<Lifecycle | null> => {
  const encoded = await git(
    ["config", "--get", configKey(feature.branch)],
    feature.repository.root,
  ).catch(() => null)
  if (!encoded) return null

  let lifecycle: Lifecycle
  try {
    lifecycle = JSON.parse(encoded) as Lifecycle
  } catch {
    throw new Error(`blocked feature=${feature.branch} reason=lifecycle-metadata-mismatch`)
  }
  if (lifecycle.version === "1") {
    lifecycle = {
      ...lifecycle,
      version: lifecycleVersion,
      acceptedHead: await git(["rev-parse", feature.branch], feature.repository.root),
      reviewCommit: null,
      reviewReady: false,
    }
    await writeLifecycle(feature, lifecycle)
  }
  if (
    lifecycle.version !== lifecycleVersion ||
    !lifecycle.id ||
    lifecycle.repository !== feature.repository.identity ||
    lifecycle.branch !== feature.branch ||
    lifecycle.base !== feature.base ||
    resolve(lifecycle.path) !== feature.path ||
    !lifecycle.acceptedHead ||
    (lifecycle.reviewCommit !== null && !lifecycle.reviewCommit) ||
    typeof lifecycle.reviewReady !== "boolean" ||
    (lifecycle.reviewReady && !lifecycle.reviewCommit)
  ) {
    throw new Error(`blocked feature=${feature.branch} reason=lifecycle-metadata-mismatch`)
  }

  return { ...lifecycle, path: resolve(lifecycle.path) }
}

const writeLifecycle = async (feature: Feature, lifecycle: Lifecycle) =>
  git(
    [
      "config",
      configKey(feature.branch),
      JSON.stringify(lifecycle),
    ],
    feature.repository.root,
  )

const featureFromLifecycle = async (cwd: string, feature: string) => {
  const repository = await repositoryFor(cwd)
  const slug = normalizeSlug(feature, "feature")
  const branch = `feature/${slug}`
  const encoded = await git(["config", "--get", configKey(branch)], repository.root).catch(
    () => null,
  )
  if (!encoded) throw new Error(`blocked feature=${branch} reason=unmanaged-or-missing`)

  let lifecycle: Lifecycle
  try {
    lifecycle = JSON.parse(encoded) as Lifecycle
  } catch {
    throw new Error(`blocked feature=${branch} reason=lifecycle-metadata-mismatch`)
  }
  const result = await featureFor(cwd, slug, lifecycle.base)
  await lifecycleFor(result)
  return result
}

const pathExists = async (path: string) => {
  try {
    await stat(path)
    return true
  } catch {
    return false
  }
}

const inspectFeature = async (feature: Feature) => {
  const worktrees = await worktreesFor(feature.repository.root)
  const target = worktrees.find((item) => resolve(item.path) === feature.path) ?? null
  const owner = worktrees.find((item) => item.branch === feature.branch) ?? null
  const baseOwner = worktrees.find((item) => item.branch === feature.base) ?? null
  const branchExists = await succeeds(
    ["show-ref", "--verify", `refs/heads/${feature.branch}`],
    feature.repository.root,
  )
  const lifecycle = await lifecycleFor(feature)
  let state = "blocked"

  if (!branchExists && !target && !lifecycle) state = "absent"
  else if (!lifecycle) state = "unmanaged"
  else if (owner && resolve(owner.path) === feature.path) state = "agent-active"
  else if (owner) state = "local-review"
  else if (target?.branch === null) state = "review-ready"
  else if (branchExists && !target) state = "cleanup-ready"

  return { state, target, owner, baseOwner, branchExists, lifecycle }
}

const requireClean = async (path: string, label: string) => {
  const repository = await repositoryFor(path)
  if (repository.dirty) throw new Error(`blocked reason=dirty-${label} path=${path}`)
  return repository
}

const formatState = (
  feature: Feature,
  state: Awaited<ReturnType<typeof inspectFeature>>,
) =>
  [
    `state=${state.state}`,
    `feature=${feature.branch}`,
    `base=${feature.base}`,
    `path=${feature.path}`,
    state.owner ? `owner=${state.owner.path}` : "owner=none",
    state.lifecycle ? `accepted=${state.lifecycle.acceptedHead}` : "accepted=none",
    state.lifecycle?.reviewCommit
      ? `review=${state.lifecycle.reviewCommit}`
      : "review=none",
  ].join(" ")

const authorize = async (
  feature: Feature,
  lifecycle: Lifecycle,
  context: ToolContext,
) => {
  const pattern = `${feature.repository.identity}:${feature.branch}:${lifecycle.id}`
  await context.ask({
    permission: "feature_lifecycle",
    patterns: [pattern],
    always: [pattern],
    metadata: {
      feature: feature.branch,
      base: feature.base,
      path: feature.path,
      operations:
        "create, detach, reattach, uncommit rejected review, fast-forward merge, remove, delete merged branch",
    },
  })
}

export const FeatureWorktreePlugin: Plugin = async ({ worktree }) => {
  const activeWorktree = await realpath(worktree)
  const lifecycle = tool({
    description:
      "Manage an authorized feature worktree lifecycle: start, prepare-review, accept-review, reject-review, finish, or status.",
    args: {
      action: tool.schema.enum([
        "start",
        "prepare-review",
        "accept-review",
        "reject-review",
        "finish",
        "status",
      ]),
      feature: tool.schema.string(),
      base: tool.schema.string().optional(),
    },
    async execute({ action, feature: requestedFeature, base }, context) {
      if (action === "start") {
        const feature = await featureFor(worktree, requestedFeature, base)
        const current = await inspectFeature(feature)

        if (current.state === "agent-active") return formatState(feature, current)
        if (current.state !== "absent" && current.state !== "unmanaged") {
          throw new Error(formatState(feature, current))
        }
        if (
          current.state === "unmanaged" &&
          (!current.target || current.target.branch !== feature.branch)
        ) {
          throw new Error(formatState(feature, current))
        }

        const acceptedHead = await git(["rev-parse", feature.base], feature.repository.root)
        const lifecycle = lifecycleData(feature, randomUUID(), acceptedHead)
        await authorize(feature, lifecycle, context)

        if (current.state === "absent") {
          if (await pathExists(feature.path)) {
            throw new Error(`blocked feature=${feature.branch} reason=path-exists path=${feature.path}`)
          }
          await mkdir(dirname(feature.path), { recursive: true })
          await git(
            ["worktree", "add", "-b", feature.branch, feature.path, feature.base],
            feature.repository.root,
          )
        }
        await writeLifecycle(feature, lifecycle)

        const created = await inspectFeature(feature)
        if (created.state !== "agent-active") {
          throw new Error(`blocked feature=${feature.branch} reason=post-create-verification`)
        }
        return formatState(feature, created)
      }

      const feature = await featureFromLifecycle(worktree, requestedFeature)
      const current = await inspectFeature(feature)

      if (action === "status") return formatState(feature, current)
      if (!current.lifecycle) throw new Error(formatState(feature, current))

      if (action === "prepare-review") {
        if (!current.target) {
          throw new Error(formatState(feature, current))
        }
        await requireClean(feature.path, "feature-worktree")
        const reviewCommit = current.lifecycle.reviewCommit ?? current.target.commit
        const branchHead = await git(["rev-parse", feature.branch], feature.repository.root)
        const parents = (
          await git(["rev-list", "--parents", "-n", "1", reviewCommit], feature.repository.root)
        ).split(" ")
        if (
          parents.length !== 2 ||
          parents[1] !== current.lifecycle.acceptedHead ||
          current.target.commit !== reviewCommit ||
          branchHead !== reviewCommit
        ) {
          throw new Error(
            `blocked feature=${feature.branch} reason=review-must-be-one-commit accepted=${current.lifecycle.acceptedHead} head=${current.target.commit}`,
          )
        }
        if (current.state === "local-review") {
          if (!current.lifecycle.reviewReady) {
            throw new Error(
              `blocked feature=${feature.branch} reason=review-not-ready state=local-review`,
            )
          }
          return formatState(feature, current)
        }
        if (current.state === "review-ready") {
          if (!current.lifecycle.reviewReady) {
            await writeLifecycle(feature, {
              ...current.lifecycle,
              reviewReady: true,
            })
          }
          return formatState(feature, await inspectFeature(feature))
        }
        if (current.state !== "agent-active" || current.lifecycle.reviewReady) {
          throw new Error(formatState(feature, current))
        }
        await authorize(feature, current.lifecycle, context)
        if (!current.lifecycle.reviewCommit) {
          await writeLifecycle(feature, {
            ...current.lifecycle,
            reviewCommit,
            reviewReady: false,
          })
        }
        await git(["switch", "--detach"], feature.path)
        await writeLifecycle(feature, {
          ...current.lifecycle,
          reviewCommit,
          reviewReady: true,
        })

        const prepared = await inspectFeature(feature)
        if (prepared.state !== "review-ready") {
          throw new Error(`blocked feature=${feature.branch} reason=post-detach-verification`)
        }
        return `${formatState(feature, prepared)} next=checkout-feature-with-lazygit-space`
      }

      if (action === "accept-review" || action === "reject-review") {
        const reviewCommit = current.lifecycle.reviewCommit
        if (!reviewCommit || !current.lifecycle.reviewReady) {
          throw new Error(`blocked feature=${feature.branch} reason=no-pending-review`)
        }
        const branchHead = await git(["rev-parse", feature.branch], feature.repository.root)
        if (
          action === "reject-review" &&
          current.state === "agent-active" &&
          branchHead === current.lifecycle.acceptedHead
        ) {
          await writeLifecycle(feature, {
            ...current.lifecycle,
            reviewCommit: null,
            reviewReady: false,
          })
          return formatState(feature, await inspectFeature(feature))
        }
        if (branchHead !== reviewCommit) {
          throw new Error(
            `blocked feature=${feature.branch} reason=review-ref-changed expected=${reviewCommit} actual=${branchHead}`,
          )
        }
        if (current.state === "local-review") {
          throw new Error(
            `${formatState(feature, current)} next=checkout-${feature.base}-with-lazygit-space`,
          )
        }
        if (
          current.state !== "review-ready" &&
          current.state !== "agent-active"
        ) {
          throw new Error(formatState(feature, current))
        }
        if (!current.target || current.target.commit !== reviewCommit) {
          throw new Error(
            `blocked feature=${feature.branch} reason=review-worktree-changed expected=${reviewCommit} actual=${current.target?.commit ?? "none"}`,
          )
        }
        await requireClean(feature.path, "feature-worktree")
        await authorize(feature, current.lifecycle, context)
        if (current.state === "review-ready") {
          await git(["switch", feature.branch], feature.path)
        }
        if (action === "reject-review") {
          await git(["reset", "--mixed", current.lifecycle.acceptedHead], feature.path)
        }
        await writeLifecycle(feature, {
          ...current.lifecycle,
          acceptedHead:
            action === "accept-review" ? reviewCommit : current.lifecycle.acceptedHead,
          reviewCommit: null,
          reviewReady: false,
        })

        const reviewed = await inspectFeature(feature)
        if (reviewed.state !== "agent-active") {
          throw new Error(`blocked feature=${feature.branch} reason=post-review-verification`)
        }
        return formatState(feature, reviewed)
      }

      if (current.lifecycle.reviewCommit) {
        throw new Error(
          `blocked feature=${feature.branch} reason=pending-review commit=${current.lifecycle.reviewCommit}`,
        )
      }
      if (current.state === "local-review") {
        throw new Error(
          `${formatState(feature, current)} next=checkout-${feature.base}-with-lazygit-space`,
        )
      }
      if (
        current.state !== "agent-active" &&
        current.state !== "review-ready" &&
        current.state !== "cleanup-ready"
      ) {
        throw new Error(formatState(feature, current))
      }
      if (!current.baseOwner) throw new Error(formatState(feature, current))
      if (resolve(current.baseOwner.path) !== feature.repository.root) {
        throw new Error(`blocked feature=${feature.branch} reason=base-not-in-primary-worktree`)
      }
      if (current.target) {
        if (activeWorktree === feature.path) {
          throw new Error(`blocked feature=${feature.branch} reason=active-worktree`)
        }
        await requireClean(feature.path, "feature-worktree")
        if (
          !(await succeeds(
            ["merge-base", "--is-ancestor", current.target.commit, feature.branch],
            feature.repository.root,
          ))
        ) {
          throw new Error(`blocked feature=${feature.branch} reason=detached-work-not-on-branch`)
        }
      }
      const acceptedHead = current.lifecycle.acceptedHead
      const branchHead = await git(["rev-parse", feature.branch], feature.repository.root)
      if (branchHead !== acceptedHead) {
        throw new Error(
          `blocked feature=${feature.branch} reason=unreviewed-head accepted=${acceptedHead} actual=${branchHead}`,
        )
      }
      await requireClean(current.baseOwner.path, "base-worktree")
      const merged = await succeeds(
        ["merge-base", "--is-ancestor", acceptedHead, feature.base],
        feature.repository.root,
      )
      if (!merged) {
        if (
          !(await succeeds(
            ["merge-base", "--is-ancestor", feature.base, acceptedHead],
            feature.repository.root,
          ))
        ) {
          throw new Error(`blocked feature=${feature.branch} reason=non-fast-forward`)
        }
      }
      await authorize(feature, current.lifecycle, context)
      if (!merged) await git(["merge", "--ff-only", acceptedHead], current.baseOwner.path)
      if (
        !(await succeeds(
          ["merge-base", "--is-ancestor", acceptedHead, feature.base],
          feature.repository.root,
        ))
      ) {
        throw new Error(`blocked feature=${feature.branch} reason=post-merge-verification`)
      }
      const finalBranchHead = await git(["rev-parse", feature.branch], feature.repository.root)
      if (finalBranchHead !== acceptedHead) {
        throw new Error(
          `blocked feature=${feature.branch} reason=review-ref-changed expected=${acceptedHead} actual=${finalBranchHead}`,
        )
      }
      if (current.target) {
        await git(["worktree", "remove", feature.path], feature.repository.root)
      }
      await git(["branch", "-d", feature.branch], feature.repository.root)

      const worktrees = await worktreesFor(feature.repository.root)
      const branchExists = await succeeds(
        ["show-ref", "--verify", `refs/heads/${feature.branch}`],
        feature.repository.root,
      )
      if (worktrees.some((item) => resolve(item.path) === feature.path) || branchExists) {
        throw new Error(`blocked feature=${feature.branch} reason=post-cleanup-verification`)
      }
      return `state=complete feature=${feature.branch} base=${feature.base}`
    },
  })

  return {
    tool: {
      feature_worktree: lifecycle,
    },
  }
}
