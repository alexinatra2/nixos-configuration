---
name: git-commit
description: Use when committing or organizing Git changes. Inspect, propose logical commits, and commit only after per-commit approval.
---

# Git Commit

Never push, amend, rebase, reset, discard, or rewrite history unless requested.

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
