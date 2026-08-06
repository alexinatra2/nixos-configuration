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

      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      assert.match(await current.execute("prepare-review"), /state=review-ready/)
      assert.equal(await git(current.worktree, "branch", "--show-current"), "")

      await git(current.repository, "switch", "feature/example")
      assert.match(await current.execute("status"), /state=local-review/)
      await git(current.repository, "switch", "master")

      assert.match(await current.execute("accept-review"), /state=agent-active/)
      assert.match(await current.execute("status"), /review=none/)

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
      await current.execute("prepare-review")
      await current.execute("accept-review")
      await writeFile(join(current.repository, "base.txt"), "base\n")
      await git(current.repository, "add", "base.txt")
      await git(current.repository, "commit", "-m", "base")

      await assert.rejects(current.execute("finish"), /non-fast-forward/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("preserves detached work that changes during review", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await current.execute("prepare-review")
      await writeFile(join(current.worktree, "detached.txt"), "detached\n")
      await git(current.worktree, "add", "detached.txt")
      await git(current.worktree, "commit", "-m", "detached")

      await assert.rejects(current.execute("prepare-review"), /review-must-be-one-commit/)
      await assert.rejects(current.execute("accept-review"), /review-worktree-changed/)
      await assert.rejects(current.execute("reject-review"), /review-worktree-changed/)
      await assert.rejects(current.execute("finish"), /pending-review/)
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
      await current.execute("prepare-review")
      await current.execute("accept-review")
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

  await suite.test("rejects a review and preserves its changes", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      const acceptedHead = await git(current.worktree, "rev-parse", "HEAD")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await current.execute("prepare-review")

      assert.match(await current.execute("reject-review"), /state=agent-active/)
      assert.equal(await git(current.worktree, "rev-parse", "HEAD"), acceptedHead)
      assert.equal(await git(current.worktree, "status", "--short"), "?? feature.txt")
      assert.equal(
        await git(current.worktree, "rev-parse", "feature/example"),
        acceptedHead,
      )
      assert.match(await current.execute("status"), /review=none/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("retries rejection after review reattachment", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      const acceptedHead = await git(current.worktree, "rev-parse", "HEAD")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await current.execute("prepare-review")
      await git(current.worktree, "switch", "feature/example")

      assert.match(await current.execute("reject-review"), /state=agent-active/)
      assert.equal(await git(current.worktree, "rev-parse", "HEAD"), acceptedHead)
      assert.equal(await git(current.worktree, "status", "--short"), "?? feature.txt")
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("requires exactly one provisional commit", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await assert.rejects(current.execute("prepare-review"), /review-must-be-one-commit/)

      await writeFile(join(current.worktree, "one.txt"), "one\n")
      await git(current.worktree, "add", "one.txt")
      await git(current.worktree, "commit", "-m", "one")
      await writeFile(join(current.worktree, "two.txt"), "two\n")
      await git(current.worktree, "add", "two.txt")
      await git(current.worktree, "commit", "-m", "two")

      await assert.rejects(current.execute("prepare-review"), /review-must-be-one-commit/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("blocks acceptance when the review branch changes", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await current.execute("prepare-review")
      await git(current.repository, "switch", "feature/example")
      await writeFile(join(current.repository, "changed.txt"), "changed\n")
      await git(current.repository, "add", "changed.txt")
      await git(current.repository, "commit", "-m", "changed")
      await git(current.repository, "switch", "master")

      await assert.rejects(current.execute("accept-review"), /review-ref-changed/)
      await assert.rejects(current.execute("reject-review"), /review-ref-changed/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("blocks finish while a review is pending", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      await current.execute("prepare-review")

      await assert.rejects(current.execute("finish"), /pending-review/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("blocks finish with an unreviewed commit", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")

      await assert.rejects(current.execute("finish"), /unreviewed-head/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("reviews consecutive commits independently", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      for (const name of ["one", "two"]) {
        await writeFile(join(current.worktree, `${name}.txt`), `${name}\n`)
        await git(current.worktree, "add", `${name}.txt`)
        await git(current.worktree, "commit", "-m", name)
        await current.execute("prepare-review")
        await current.execute("accept-review")
      }

      assert.match(await current.execute("finish"), /state=complete/)
      assert.equal(await git(current.repository, "show", "HEAD:two.txt"), "two")
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("does not accept a review before detachment completes", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")
      const reviewCommit = await git(current.worktree, "rev-parse", "HEAD")
      const key = "branch.feature/example.opencode-lifecycle"
      const lifecycle = JSON.parse(await git(current.repository, "config", "--get", key))
      await git(
        current.repository,
        "config",
        key,
        JSON.stringify({ ...lifecycle, reviewCommit, reviewReady: false }),
      )

      await assert.rejects(current.execute("accept-review"), /no-pending-review/)
      assert.match(await current.execute("prepare-review"), /state=review-ready/)
      assert.match(await current.execute("accept-review"), /state=agent-active/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("migrates version one lifecycle metadata", async () => {
    const current = await fixture()
    try {
      await current.execute("start")
      const key = "branch.feature/example.opencode-lifecycle"
      const lifecycle = JSON.parse(await git(current.repository, "config", "--get", key))
      const { acceptedHead: _, reviewCommit: __, reviewReady: ___, ...legacy } = lifecycle
      await git(
        current.repository,
        "config",
        key,
        JSON.stringify({ ...legacy, version: "1" }),
      )

      const head = await git(current.worktree, "rev-parse", "HEAD")
      assert.match(await current.execute("status"), new RegExp(`accepted=${head}`))
      const migrated = JSON.parse(await git(current.repository, "config", "--get", key))
      assert.equal(migrated.version, "2")
      assert.equal(migrated.acceptedHead, head)
      assert.equal(migrated.reviewCommit, null)
      assert.equal(migrated.reviewReady, false)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })

  await suite.test("does not accept commits when adopting an unmanaged worktree", async () => {
    const current = await fixture()
    try {
      const baseHead = await git(current.repository, "rev-parse", "master")
      await git(
        current.repository,
        "worktree",
        "add",
        "-b",
        "feature/example",
        current.worktree,
        "master",
      )
      await writeFile(join(current.worktree, "feature.txt"), "feature\n")
      await git(current.worktree, "add", "feature.txt")
      await git(current.worktree, "commit", "-m", "feature")

      assert.match(await current.execute("start"), new RegExp(`accepted=${baseHead}`))
      await assert.rejects(current.execute("finish"), /unreviewed-head/)
      assert.match(await current.execute("prepare-review"), /state=review-ready/)
    } finally {
      await rm(current.root, { recursive: true, force: true })
    }
  })
})
