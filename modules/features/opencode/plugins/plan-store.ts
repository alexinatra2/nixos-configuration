import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { tool, type Plugin } from "@opencode-ai/plugin";
import { repositoryId } from "./lib/repository-id";

export const PlanStorePlugin: Plugin = async ({ worktree }) => {
  const id = await repositoryId(worktree);
  const planPath = join(homedir(), ".local", "share", "opencode", "plans", id, "PLAN.md");

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
