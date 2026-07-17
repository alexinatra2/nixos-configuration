---
name: git-commit
description: Use when committing or organizing Git changes. Inspect, propose logical commits, and commit only after per-commit approval.
---

# Git Commit

Never push, amend, rebase, reset, discard changes, or rewrite history unless
explicitly requested.

Before proposing:

1. Confirm the repository root.
2. Inspect status, relevant diffs, stats, and recent commit style.
3. Do not change the index.
4. Exclude suspicious data, generated output, vendored files, unrelated
   changes, and unrelated lockfile churn unless explicitly confirmed.

Propose the smallest coherent commit with its message, files or hunks,
rationale, and exclusions. If scope is unclear, ask.

## Plan Iteration

When called by `plan-iteration`, commit only its active step.

Before `question`, give only:

```text
<short summary>

Changed files:
- <exact path>
- <exact path>

Proposed commit: <message>
Definition of done: <brief condition>
How to verify: <brief manual check>
```

Use:

- `Commit and start next step`
- `Fix based on feedback`
- `Just commit`

Otherwise, use:

- `Approve commit`
- `Revise scope or message`
- `Skip commit`
- `Stop workflow`

Never commit without approval for the exact proposal.

After approval:

1. Stage only the approved scope.
2. Verify the staged diff.
3. Commit.
4. Report the commit.
5. Reinspect remaining changes and re-propose grouping.

Run relevant inexpensive checks before proposing a commit.
