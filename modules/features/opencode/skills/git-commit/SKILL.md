---
name: git-commit
description: Use when committing or organizing Git changes. Inspect, propose logical commits, and commit only after per-commit approval.
---

# Git Commit

Use only for commits. Never push, amend, rebase, reset, discard changes, or rewrite history unless explicitly requested.

Before proposing:

1. Confirm the repository root.
2. Inspect status; staged, unstaged, untracked, renamed, and deleted changes; relevant diffs and stats; and recent commit style.
3. Use focused diffs for unclear files or hunks.
4. Do not change the index.
5. Do not search for private data. Warn about and exclude suspicious data encountered while reviewing requested diffs, generated output, vendored files, unrelated changes, and unrelated lockfile churn. Include them only with explicit confirmation.

Propose the smallest coherent ordered commits. For each, give:

- Message.
- Files and hunks.
- Rationale.
- Exclusions and warnings.

If nothing is appropriate, stop. If grouping is unclear, ask.

For each proposal, use `question` with:

- `Approve commit`
- `Revise scope or message`
- `Skip commit`
- `Stop workflow`

Never commit without approval for that exact proposal. On revision, update and re-ask. On skip, leave changes uncommitted. On stop, make no further changes.

After approval:

1. Stage only the approved scope; preserve unrelated staged work where possible.
2. Verify the staged diff matches the proposal.
3. Commit with the approved message.
4. Report the commit.
5. Reinspect remaining changes and re-propose grouping.

Do not commit files merely because they are staged or include unapproved changes. Run relevant inexpensive checks before proposing a commit.
