---
name: git-commit
description: Git commit workflow for inspecting changes, proposing safe logical commits, and creating commits only after explicit per-commit approval. Use when the user asks to commit, stage for commit, or organize changes into commits.
---

# Git Commit

Use this skill only to prepare and create Git commits. Never push, amend,
rebase, reset existing commits, or otherwise modify history unless the user
explicitly requests that action.

## Inspect First

Before proposing any commit, inspect the current repository and all relevant
changes:

1. Confirm the directory is a Git repository and identify its root.
2. Inspect the working tree, including staged, unstaged, untracked, renamed,
   and deleted files.
3. Inspect both staged and unstaged diffs, diff statistics, and enough recent
   history to match the repository's commit-message convention.
4. Use focused diffs for files or hunks whose intent is unclear.
5. Treat the current index as user state. Do not change staging before the user
   approves a proposed commit.

Look specifically for likely secrets or credentials, including `.env` files,
private keys, tokens, passwords, certificates, connection strings, and
high-entropy values. Also identify generated or build artifacts, vendored
output, lockfile churn unrelated to the change, and changes unrelated to the
user's stated goal.

If any suspicious content is present, warn the user clearly before proposing it
for a commit. Exclude it by default. Do not stage or commit it unless the user
explicitly confirms that it is intentional and safe. Likewise, warn before
including generated artifacts or unrelated changes.

## Propose Logical Commits

Decide whether the changes form one logical commit or should be split into
independent commits. Prefer the smallest independently reviewable commits that
build or test coherently. Do not split tightly coupled changes just to make
more commits.

Present an ordered proposal before making any changes to the index. For every
proposed commit, include:

- The proposed commit message.
- The exact files and, where applicable, hunks to include.
- A brief rationale for why the changes belong together and why the ordering is
appropriate.
- Any excluded changes and applicable safety warnings.

If there are no appropriate changes to commit, say so and stop. If grouping is
ambiguous, ask the user before staging anything.

## Approval And Commit Loop

Handle proposed commits in order. For each proposal, use the interactive
`question` tool to request explicit approval with these choices:

- `Approve commit`
- `Revise scope or message`
- `Skip commit`
- `Stop workflow`

Never create a commit without the user selecting `Approve commit` for that
exact proposal.

On `Revise scope or message`, collect the requested changes, update the
proposal, and request approval again. On `Skip commit`, leave its changes
uncommitted and continue only if another independent proposal remains. On `Stop
workflow`, make no further staging or commits.

After approval:

1. Stage only the approved files and hunks. Preserve unrelated staged work
where possible and explain any required index adjustment before making it.
2. Reinspect the staged diff and verify it matches the approved scope exactly.
3. Create exactly that commit using the approved message.
4. Report the new commit identifier and a concise summary.
5. Reinspect the remaining working tree, staged state, and relevant diffs
before deciding whether the next proposed grouping is still correct.

Earlier commits can change the correct grouping of later changes. Re-propose
the remaining commits after every successful commit rather than relying on an
outdated plan.

## Guardrails

- Do not commit changes merely because they are already staged.
- Do not silently include extra files or hunks.
- Do not use `--amend`, history rewriting, force operations, or push commands
unless explicitly requested.
- Do not discard, reset, or revert uncommitted changes to make the tree look
cleaner.
- If a check is relevant and inexpensive, run it before proposing the affected
commit and report the result.
