import { createHash, randomUUID } from "node:crypto";
import { execFile } from "node:child_process";
import { mkdir, readFile, realpath, rename, rm, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { promisify } from "node:util";
import { tool, type Plugin } from "@opencode-ai/plugin";

const execFileAsync = promisify(execFile);

export const PlanStorePlugin: Plugin = async ({ worktree }) => {
  const worktreeList = (
    await execFileAsync("git", ["worktree", "list", "--porcelain"], {
      cwd: worktree,
    })
  ).stdout;
  const primary = worktreeList.split("\n").find((line) => line.startsWith("worktree "));
  if (!primary) throw new Error("repository has no primary worktree");
  const repositoryRoot = await realpath(primary.slice("worktree ".length));
  const repositoryId = createHash("sha256").update(repositoryRoot).digest("hex");
  const planPath = join(homedir(), ".local", "share", "opencode", "plans", repositoryId, "PLAN.md");

  await mkdir(dirname(planPath), { recursive: true });

  return {
    tool: {
      plan_read: tool({
        description: "Read the current repository implementation plan.",
        args: {},
        async execute() {
          try {
            return await readFile(planPath, "utf8");
          } catch {
            return "No plan exists for this repository.";
          }
        },
      }),
      plan_write: tool({
        description: "Create or replace the current repository implementation plan.",
        args: {
          content: tool.schema.string(),
        },
        async execute({ content }) {
          const temporaryPath = `${planPath}.${randomUUID()}.tmp`;
          try {
            await writeFile(temporaryPath, content);
            await rename(temporaryPath, planPath);
          } finally {
            await rm(temporaryPath, { force: true });
          }
          return "Plan updated.";
        },
      }),
    },
  };
};
