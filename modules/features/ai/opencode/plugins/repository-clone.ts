import { mkdir, rm } from "node:fs/promises"
import { tool, type Plugin } from "@opencode-ai/plugin"

export const RepositoryClonePlugin: Plugin = async ({ $ }) => ({
  tool: {
    clone_repository: tool({
      description:
        "Clone a git repository into a temporary directory. Returns the path to the cloned repository.",
      args: {
        url: tool.schema.string(),
      },
      async execute({ url }) {
        const lsResult = await $.nothrow()`git ls-remote ${url}`
        if (lsResult.exitCode !== 0) {
          return `Invalid repository URL: ${url}`
        }

        const { stdout } = await $`mktemp -d`
        const dir = stdout.trim()
        await mkdir(dir, { recursive: true })

        const result = await $`git clone --depth=1 ${url} ${dir}`
        if (result.exitCode !== 0) {
          await rm(dir, { recursive: true, force: true })
          return `Clone failed: ${(await result).text()}`
        }

        return dir
      },
    }),
    cleanup_clone: tool({
      description: "Remove a cloned repository directory.",
      args: {
        path: tool.schema.string(),
      },
      async execute({ path }) {
        try {
          await rm(path, { recursive: true, force: true })
          return "Clone removed."
        } catch (e) {
          return `Failed to remove clone: ${path}`
        }
      },
    }),
  },
})
