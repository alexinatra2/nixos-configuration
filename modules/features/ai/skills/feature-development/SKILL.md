---
name: feature-development
description: Use when starting, reviewing, resuming, or finishing non-trivial feature development in a managed Git worktree.
---

# Feature Development

Delegate worktree housekeeping to `feature_worktree`. One lifecycle approval
covers create, review handoff, resume, fast-forward merge, and cleanup.

Do not use for trivial, low-risk changes that are isolated and quick to verify.

## Start

1. Inspect repository status and worktrees.
2. Derive the feature name and base; ask only when materially ambiguous.
3. Call `feature_worktree` with `action=start`.
4. Target all work at the returned absolute path.

## Review

Require committed changes and a clean feature worktree, then call
`feature_worktree` with `action=prepare-review`.

After user review, inspect `action=status`. Wait while the state is
`local-review`; call `action=resume` when the feature branch is free.

## Finish

Run focused checks, commit approved changes, and call `feature_worktree` with
`action=finish`.

Stop on a blocked state. Never stash, reset, force checkout, rebase, push,
delete remote branches, or remove unmerged work.
