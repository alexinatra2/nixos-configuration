---
name: plan-iteration
description: Use to create, resume, or execute a repository plan with per-step approval.
---

# Plan Iteration

Use `plan_read` and `plan_write` for the current repository plan. Do not
create or manage plan paths.

During planning, create or update the plan. Record the goal, numbered steps,
their `pending`, `in_progress`, `completed`, or `blocked` status, and brief
notes for checks, commits, decisions, and blockers.

## Execute

When explicitly invoked in build mode, load the plan and execute all remaining
steps.

For each step:

1. Give a brief implementation summary.
2. Use `question`:
   - `Implement this step`
   - `Skip this step`
   - `Stop execution`
3. Implement only an approved step, run focused checks, report briefly, and
   update the plan.
4. Invoke `git-commit` with the step scope, definition of done, and manual
   verification.

For plan-iteration commits, `git-commit` lists exact changed files before its
`question` and uses:

- `Commit and start next step`
- `Fix based on feedback`
- `Just commit`

`Fix based on feedback`: update only this step, rerun checks, update the plan,
and invoke `git-commit` again.

`Commit and start next step`: commit, update the plan with the commit ID, and
continue.

`Just commit`: commit, update the plan with the commit ID, and stop.

Without a commit, use:

- `Accept and start next step`
- `Fix based on feedback`
- `Accept and stop`

Never commit without a displayed commit action.
