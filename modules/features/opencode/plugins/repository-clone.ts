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
        const lsResult = await $`git ls-remote ${url}`.nothrow().quiet()
        if (lsResult.exitCode !== 0) {
          return `Invalid repository URL: ${url}`
        }

        const dir = (await $`mktemp -d`.text()).trim()
        await mkdir(dir, { recursive: true })

        const result = await $`git clone --quiet --depth=1 --single-branch ${url} ${dir}`.nothrow().quiet()
        if (result.exitCode !== 0) {
          await rm(dir, { recursive: true, force: true })
          return `Clone failed: ${url}`
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
