---
name: milestone-driver
description: Use when driving a sequence of independent milestones through feature-development, one worktree per milestone, with a decision point between each.
---

# Milestone Driver

Orchestrate a plan's milestones through `feature-development`, one worktree at
a time. Each milestone becomes its own branch. After each merge, pause for a
decision before continuing.

## Precondition

The active session must have a loaded plan from `plan-iteration` with numbered
milestones. Each milestone should be a self-contained deliverable that can be
shipped independently.

## Loop

For each remaining milestone in the plan, repeat:

1. Call `feature_worktree` with `action=start`, `feature=<milestone-slug>`.
   Use the returned path as the work target.
2. Delegate implementation to `feature-development` for this milestone only.
3. Call `feature_worktree` with `action=finish`. This fast-forwards the feature
   branch into the base and removes the worktree.
4. Update the plan with the milestone's commit reference and mark it done.
5. Ask the user via `question`:

   - If only one milestone remains: `Start next milestone` / `Stop workflow`.
   - If multiple remain: list each remaining milestone as its own option
     (e.g. `Milestone 1: auth`, `Milestone 2: search`), plus `Continue with
     next in order`, `Stop workflow`.
   - If all remaining milestones are sequential: `Continue with next`,
     `Stop workflow`.

Treat the user's free-text answer as a milestone selection when it names one.
Stop on `Stop workflow`.

## Rules

- Do not start the next milestone until the previous `finish` completes.
- Do not modify files outside the active worktree path.
- Do not push, force, or rewrite history on the base branch.
- If `feature_worktree` reports a blocked state, stop and report the blocker
  rather than bypassing.
