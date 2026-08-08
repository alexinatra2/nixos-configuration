import { tool, type Plugin } from "@opencode-ai/plugin";

export const HandoffBundlePlugin: Plugin = async ({ $, directory, worktree }) => {
  const root = worktree || directory;

  return {
    tool: {
      handoff_bundle: tool({
        description:
          "Bundle the current workspace into a tar.gz archive for handoff to a local model. Excludes .git and secrets.",
        args: {},
        async execute(_args, _context) {
          const tmpDir = (await $`mktemp -d`.text()).trim();
          const staging = `${tmpDir}/workspace`;
          const gitState = `${tmpDir}/git-state`;

          await $`mkdir -p ${staging} ${gitState}`;

          // Copy workspace, excluding .git and secrets.
          await $`tar -C ${root} -cf - \
            --exclude=.git \
            --exclude='.env*' \
            --exclude='*.key' \
            --exclude='*.pem' \
            --exclude='*.secret' \
            --exclude='node_modules' \
            --exclude='.venv' \
            . | tar -C ${staging} -xzf -`;

          // Gathers deterministic git state for the local model.
          await $`git -C ${root} status --porcelain=v1 -b > ${gitState}/status.txt`;
          await $`git -C ${root} diff > ${gitState}/diff.patch`;
          await $`git -C ${root} diff --staged > ${gitState}/diff-staged.patch`;
          await $`git -C ${root} log --oneline -20 > ${gitState}/log.txt`;
          await $`git -C ${root} branch -vv > ${gitState}/branches.txt`;
          await $`git -C ${root} worktree list --porcelain > ${gitState}/worktrees.txt`;
          await $`date -u +"%Y-%m-%dT%H:%M:%SZ" > ${gitState}/timestamp.txt`;

          // Final archive.
          const ts = Date.now();
          const archive = `${tmpDir}/handoff-${ts}.tar.gz`;
          await $`tar -czf ${archive} -C ${tmpDir} workspace git-state`;

          return archive;
        },
      }),
    },
  };
};
