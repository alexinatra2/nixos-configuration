---
name: plan-iteration
description: Use to create, resume, or execute a repository plan with per-step approval.
---

# Plan Iteration

Use `plan_read` and `plan_write`. Record the goal, numbered steps, status,
checks, commits, decisions, and blockers.

## Plan

Present the plan in chat and ask the user to reply `approve`, `stop`, or type
revision feedback directly.

## Execute

1. Load the plan.
2. Invoke `feature-development` start before the first remaining step.
3. Record and use its absolute worktree path for all work.
4. Keep the active session open.

For each step, summarize it and use `question` with:

- `Implement this step`
- `Skip this step`
- `Stop execution`

Implement only an approved step. Run focused checks, update the plan, and invoke
`git-commit`. Apply feedback only to the current step and record its commit
before continuing.

Use `feature-development` review for user verification. Invoke
`feature-development` finish after all steps and checks complete.
