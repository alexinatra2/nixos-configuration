---
name: feature-development
description: Use for starting or finishing feature development in a confirmed branch-backed Git worktree.
---

# Feature Development

Manage one feature per Git worktree. Confirm exact create, merge, and cleanup
operations before mutation.

## Start

1. Inspect the repository, current branch/status, default branch, and
   worktrees. Derive a recommended name, branch, base, and path.
2. Use `question` before preview/create. Show the recommended name first and
   let the user type a custom name. Include `Cancel feature development`.
   Do not derive a name silently or create without an answer.
3. Show the selected values and exact `git worktree add -b <branch> <path> <base>`
   command. Ask:
   - `Create worktree`
   - `Type your own answer` (free text; not a directly submittable revise action)
   - `Cancel`
4. Repeat with the typed answer when revising. On either cancel option, stop
   without calling preview/create or changing Git.
5. Before approved creation, recheck collisions. Create and verify the
   worktree, then print its branch, path, and `opencode "<path>"`.

Do not commit, stash, push, copy ignored files, install dependencies, or run
hooks unless requested.

## Finish

1. Inspect the repository root, current worktree and branch, status, worktrees,
   likely base branch, and commits relative to it.
2. Ask for missing values if detached or ambiguous.
3. Run focused checks. If dirty, invoke `git-commit`; merge only committed
   changes from a clean feature worktree.
4. Locate the base branch worktree. Require it to be clean. Do not stash,
   discard, reset, pull, rebase, or switch it automatically.
5. Show both branches and paths, commits, checks, cleanup feasibility, and the
   exact merge command. Ask:
   - `Merge locally`
   - `Revise merge`
   - `Cancel`
6. Recheck both worktrees, then merge from the base worktree. Follow repository
   conventions; otherwise use `git merge <feature-branch>`.
7. On failure or conflict, stop and preserve the branch and worktree. Verify a
   successful merge before cleanup.

## Cleanup

Show exact removal and branch deletion commands, then ask:

- `Remove worktree and branch`
- `Keep worktree and branch`
- `Cancel`

Never delete an unmerged branch. If this session is inside the feature
worktree, print cleanup commands to run from the base worktree after closing
the session. Otherwise recheck cleanliness, remove the worktree, delete only
the merged local branch, prune metadata, and verify.

Never push or delete a remote branch unless requested.
