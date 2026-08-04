---
name: git-commit
description: Use when committing or organizing Git changes. Inspect, propose logical commits, and commit only through the applicable approval workflow.
---

# Git Commit

Never push, amend, rebase, reset, discard, or rewrite history unless explicitly
allowed by managed feature review.

Before proposing:

1. Inspect the repository root, status, diff, stats, and recent commit style.
2. Do not stage files.
3. Exclude suspicious, generated, vendored, unrelated, or secret data.
4. Propose the smallest coherent commit. Ask if scope is unclear.

## Approval

For `plan-iteration`, commit only its active step.

Before `question`, give only:

```text
<short summary>

Changed files:
- <exact path>

Proposed commit: <message>
Definition of done: <condition>
How to verify: <check>
```

For `plan-iteration`, offer:

- `Commit and start next step`
- `Just commit`

Otherwise, offer:

- `Approve commit`
- `Skip commit`
- `Stop workflow`

Treat free text as revision feedback and re-propose. Never commit without exact
approval.

After approval, stage only the approved scope, verify it, commit, report the
commit, and inspect remaining changes.

## Managed Feature Review

When `feature-development` requests managed feature review:

1. Stage only the proposed scope, verify it, and create one provisional commit
   without asking for prior approval.
2. Call `feature_worktree` with `action=prepare-review`.
3. Present the standard proposal, replacing `Skip commit` with `Reject commit`.
4. Ask only after the tool reports `review-ready`.
5. Treat approval as acceptance of the existing provisional commit.
6. Treat rejection or free-text feedback as rejection of that commit.
7. After the feature branch is free, call `action=accept-review` or
   `action=reject-review` accordingly.
8. On rejection, revise the preserved changes and submit a new provisional
   commit.

Never create another provisional commit while review is pending.
