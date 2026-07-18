import { createHash } from "node:crypto";
import { mkdir, readFile, realpath, rename, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { tool, type Plugin } from "@opencode-ai/plugin";

export const PlanStorePlugin: Plugin = async ({ worktree }) => {
  const repositoryRoot = await realpath(worktree);
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
          const temporaryPath = `${planPath}.tmp`;
          await writeFile(temporaryPath, content);
          await rename(temporaryPath, planPath);
          return "Plan updated.";
        },
      }),
    },
  };
};
