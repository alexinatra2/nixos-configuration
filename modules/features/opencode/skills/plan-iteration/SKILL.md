---
name: plan-iteration
description: Use when creating, resuming, or executing an implementation plan one approved step at a time.
---

# Plan Iteration

Implement one numbered step per pass unless explicitly asked otherwise.

## State

Use `.opencode/plan-iteration/PLAN.md` at the repository root.

In a Git repository, add `.opencode/plan-iteration/` to `.git/info/exclude`
when needed. Do not change tracked ignore files. Verify the plan is not
untracked.

Record:

- Goal and context.
- Numbered steps with `pending`, `in_progress`, `completed`, or `blocked`.
- Active step.
- Resume notes: decisions, checks, commits, and blockers.

## Start Or Resume

For a session plan:

1. Refine it into ordered, executable steps.
2. Ask only for missing material requirements.
3. Save and show the plan.
4. Use `question` to request approval before implementation.

On revision, update, show, and reapprove the plan.

For an existing project:

1. Find the default plan, then other local plan files.
2. Use `question` to let the user select one or provide a path.
3. Compare it with repository state.
4. Resume at the first incomplete or inconsistent step.

If plan and repository disagree, explain the difference and use `question` to
ask whether to reconcile the plan, revise the repository for a chosen step, or
stop.

## Execute

For the active step:

1. State its number and objective.
2. Implement only that step.
3. Run focused checks.
4. Briefly summarize changes and results.
5. Update plan state and notes.

For suitable Git changes, apply `git-commit` inspection and safety rules. Do
not include other plan steps. If one step needs multiple commits, explain why
and request approval to split it.

Use `question` and present:

```text Proposed commit: <message>

How to verify: <short check> ```

For a commit, provide exactly:

- `Commit and start next step`
- `Fix based on feedback`
- `Just commit`

`Fix based on feedback`: collect feedback, update only the active step, rerun
checks, update state, and present the decision again.

`Commit and start next step`: commit the approved proposal, mark the step
complete with its commit ID, then start the next step.

`Just commit`: commit the approved proposal, mark the step complete with its
commit ID, then stop.

Never commit without selecting a displayed commit action.

Without a suitable commit or Git repository, provide:

- `Accept and start next step`
- `Fix based on feedback`
- `Accept and stop`

Update state after each acceptance, commit, block, or discrepancy.
