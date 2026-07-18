import { createHash } from "node:crypto";
import { realpath } from "node:fs/promises";

export async function repositoryId(worktree: string): Promise<string> {
  const repositoryRoot = await realpath(worktree);
  return createHash("sha256").update(repositoryRoot).digest("hex");
}
