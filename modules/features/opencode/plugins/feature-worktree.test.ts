import { execFile } from "node:child_process"
import { mkdtemp, rm, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { promisify } from "node:util"
import assert from "node:assert/strict"
import test from "node:test"
import { FeatureWorktreePlugin } from "./feature-worktree.ts"

const execFileAsync = promisify(execFile)

const git = async (cwd: string, ...args: string[]) => {
  const result = await execFileAsync("git", args, { cwd })
  return result.stdout.trim()
}

const fixture = async () => {
  const root = await mkdtemp(join(tmpdir(), "feature-worktree-test-"))
  const repository = join(root, "repository")
  await execFileAsync("git", ["init", "-b", "master", repository])
  await git(repository, "config", "user.name", "Feature Test")
  await git(repository, "config", "user.email", "feature@example.invalid")
  await writeFile(join(repository, "README.md"), "initial\n")
  await git(repository, "add", "README.md")
  await git(repository, "commit", "-m", "initial")
  process.env.OPENCODE_WORKTREE_ROOT = join(root, "worktrees")

  const plugin = await FeatureWorktreePlugin({ worktree: repository } as never)
  const lifecycle = plugin.tool?.feature_worktree
  assert(lifecycle)
  let approvals = 0
  const approved = new Set<string>()
  const context = {
    ask: async (input: { patterns: string[]; always: string[] }) => {
      if (input.patterns.every((pattern) => approved.has(pattern))) return
      approvals += 1
      for (const pattern of input.always) approved.add(pattern)
    },
  } as never
  const execute = (action: string, feature = "example", base?: string) =>
    lifecycle.execute({ action, feature, base }, context)

  return {
    root,
    repository,
    worktree: join(root, "worktrees", "repository", "example"),
    execute,
    approvals: () => approvals,
  }
}

test("feature worktree lifecycle", async (suite) => {
  await suite.test("transfers branch ownership and finishes", async () => {
    const current = await fixture()
    try {
      assert.match(await current.execute("start"), /state=agent-active/)
      assert.equal(current.approvals(), 1)

      assert.match(await current.execute("prepare-review"), /state=review-ready/)
      assert.equal(await git(current.worktree, "branch", "--show-current"), "")

      await git(current.repository, "switch", "feature/example")
      assert.match(await current.execute("status"), /state=local-review/)
      await git(current.repository, "switch", "master")

      assert.match(await current.execute("resume"), /state=agent-active/)
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")

      assert.match(await current.execute("finish"), /state=complete/)
      assert.equal(await git(current.repository, "branch", "--show-current"), "master")
      assert.equal(
        await git(current.repository, "show", "HEAD:feature.txt"),
        "feature",
      )
      assert.equal(
        await git(current.repository, "show-ref", "--verify", "refs/heads/feature/example").catch(
          () => "missing",
        ),
        "missing",
      )
      assert.equal(current.approvals(), 1)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("refuses dirty review preparation", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "dirty.txt"), "dirty\n")
      await assert.rejects(current.execute("prepare-review"), /dirty-feature-worktree/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("requires a local base branch", async () => {
    const current = await fixture()
    try {
      await assert.rejects(
        current.execute("start", "example", "HEAD"),
        /base-not-local-branch/,
      )
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("refuses a non-fast-forward finish", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await writeFile(join(current.repository, "base.txt"), "base\n")
      await git(current.repository, "add", "base.txt")
      await git(current.repository, "commit", "-m", "base")

      await assert.rejects(current.execute("finish"), /non-fast-forward/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("preserves detached work that is not on the feature branch", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await current.execute("prepare-review")
      await writeFile(join(current.worktree, "detached.txt"), "detached\n")
      await git(current.worktree, "add", "detached.txt")
      await git(current.worktree, "commit", "-m", "detached")

      await assert.rejects(current.execute("resume"), /detached-work-not-on-branch/)
      await assert.rejects(current.execute("finish"), /detached-work-not-on-branch/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("resumes cleanup after worktree removal", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await git(current.repository, "merge", "--ff-only", "feature/example")
      await git(current.repository, "worktree", "remove", current.worktree)

      assert.match(await current.execute("finish"), /state=complete/)
      assert.equal(
        await git(current.repository, "show-ref", "--verify", "refs/heads/feature/example").catch(
          () => "missing",
        ),
        "missing",
      )
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("does not remove the active OpenCode worktree", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      const plugin = await FeatureWorktreePlugin({ worktree: current.worktree } as never)
      const lifecycle = plugin.tool?.feature_worktree
      assert(lifecycle)

      await assert.rejects(
        lifecycle.execute(
          { action: "finish", feature: "example" },
          { ask: async () => undefined } as never,
        ),
        /active-worktree/,
      )
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })
})
