import { execFile } from "node:child_process"
import { mkdtemp, rm, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { promisify } from "node:util"
import assert from "node:assert/strict"
import test from "node:test"
import { PlanStorePlugin } from "./plan-store.ts"

const execFileAsync = promisify(execFile)

const git = async (cwd: string, ...args: string[]) => {
  const result = await execFileAsync("git", args, { cwd })
  return result.stdout.trim()
}

test("shares one plan across linked worktrees", async () => {
  const root = await mkdtemp(join(tmpdir(), "plan-store-test-"))
  const repository = join(root, "repository")
  const linked = join(root, "linked")
  process.env.HOME = join(root, "home")

  try {
    await execFileAsync("git", ["init", "-b", "master", repository])
    await git(repository, "config", "user.name", "Plan Test")
    await git(repository, "config", "user.email", "plan@example.invalid")
    await writeFile(join(repository, "README.md"), "initial\n")
    await git(repository, "add", "README.md")
    await git(repository, "commit", "-m", "initial")
    await git(repository, "worktree", "add", "-b", "feature/example", linked)

    const primaryPlugin = await PlanStorePlugin({ worktree: repository } as never)
    const linkedPlugin = await PlanStorePlugin({ worktree: linked } as never)
    const primaryWrite = primaryPlugin.tool?.plan_write
    const linkedRead = linkedPlugin.tool?.plan_read
    const linkedWrite = linkedPlugin.tool?.plan_write
    assert(primaryWrite)
    assert(linkedRead)
    assert(linkedWrite)

    await primaryWrite.execute({ content: "shared plan\n" }, {} as never)
    assert.equal(await linkedRead.execute({}, {} as never), "shared plan\n")

    await Promise.all([
      primaryWrite.execute({ content: "primary plan\n" }, {} as never),
      linkedWrite.execute({ content: "linked plan\n" }, {} as never),
    ])
    assert.match(await linkedRead.execute({}, {} as never), /^(primary|linked) plan\n$/)
  } finally {
    await rm(root, { recursive: true, force: true })
  }
})
