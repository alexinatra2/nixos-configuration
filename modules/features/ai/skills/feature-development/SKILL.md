---
name: feature-development
description: Use when starting, reviewing, resuming, or finishing non-trivial feature development in a managed Git worktree.
---

# Feature Development

Delegate worktree housekeeping to `feature_worktree`. One lifecycle approval
covers create, review handoff, accepted review reattachment, rejected review
uncommit, fast-forward merge, and cleanup.

Do not use for trivial, low-risk changes that are isolated and quick to verify.

## Start

1. Inspect repository status and worktrees.
2. Derive the feature name and base; ask only when materially ambiguous.
3. Call `feature_worktree` with `action=start`.
4. Target all work at the returned absolute path.

## Commit Review

Review each commit independently:

1. Run focused checks and use `git-commit` in managed feature review mode.
2. Create exactly one provisional commit.
3. Call `feature_worktree` with `action=prepare-review` before asking the user
   to approve or reject the commit.
4. Let the user check out and inspect the feature branch.
5. Before processing the decision, inspect `action=status`. Wait while the
   state is `local-review`.
6. On approval, call `action=accept-review`.
7. On rejection or revision feedback, call `action=reject-review`, revise the
   preserved working-tree changes, and repeat.

Stop on changed refs, unexpected commits, dirty detached worktrees, or blocked
ownership. Never bypass a pending review.

## Finish

Run focused checks, require no pending or unreviewed commits, and call
`feature_worktree` with `action=finish`.

Never stash, force checkout, rebase, push, delete remote branches, or remove
unmerged work. Reset only through `action=reject-review`.
