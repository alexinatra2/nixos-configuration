---
name: plan-iteration
description: Implementation-plan workflow for creating or resuming an ephemeral project plan, completing exactly one step at a time, and requesting approval before each commit. Use when the user asks to make, continue, execute, or iterate on an implementation plan.
---

# Plan Iteration

Use this skill to turn a session plan into an executable, resumable
implementation workflow, or to resume an existing workflow. Do not implement
more than one numbered plan step in a single pass unless the user explicitly
requests it.

## Plan State

The default ephemeral plan file for a project is
`.opencode/plan-iteration/PLAN.md` at the Git repository root. It is local
working state, not project source.

When creating that file inside a Git repository:

1. Check whether `.opencode/plan-iteration/` is already ignored.
2. If it is not, add that exact directory entry to the repository's
   `.git/info/exclude` file.
3. Do not modify tracked `.gitignore` files merely to store plan state.
4. Verify that the plan file does not appear as an untracked change.

The plan file must contain:

- A concise goal and relevant repository context.
- A numbered list of implementation steps.
- A completion state for every step: `pending`, `in_progress`, `completed`, or
`blocked`.
- The current active step number.
- Resume notes, including important decisions, checks run, commit identifiers,
and unresolved issues.

Use a readable Markdown structure so a later session can update it without
ambiguity.

## Start A Plan

When the current session contains a plan or implementation outline:

1. Refine it into concrete, ordered, independently executable numbered steps.
2. If the goal or scope is missing, ask the user for the minimum clarification
needed before writing the plan.
3. Save the refined plan to the ephemeral plan file.
4. Show the complete finalized plan to the user.
5. Use the interactive `question` tool to ask for approval before implementing
any step.

Do not begin implementation until the user explicitly approves the finalized
plan. If the user requests a revision, update the plan file, show the revised
plan, and ask for approval again.

## Resume A Plan

When invoked in an existing project:

1. Determine the project root when available.
2. Search first for `.opencode/plan-iteration/PLAN.md` at that root, then for
other clearly named local plan files in the project.
3. Offer the user the discovered plan files through the interactive `question`
tool, and also allow the user to provide another path.
4. Read the selected plan, inspect its recorded completion state, and compare
it with the actual repository state, including relevant files, Git status,
diffs, commit history, and prior checks where possible.
5. Resume at the first `pending`, `in_progress`, `blocked`, or
repository-inconsistent step.

If the stored plan and the repository disagree, explain the specific
discrepancy before editing anything. Use an interactive question to ask whether
to reconcile the plan to the repository, revise the repository to match an
explicitly chosen plan step, or stop. Do not guess which source of truth wins.

## Execute One Step

For each active numbered step:

1. Clearly state the step number and objective.
2. Implement only that step.
3. Run the narrowest relevant checks for that step.
4. Summarize the files changed and check results.
5. Update the ephemeral plan file with current progress and resume notes.

If the directory is a Git repository and the step produced appropriate changes,
apply the `git-commit` skill's inspection, grouping, and safety rules before
proposing a commit. Do not combine unrelated changes from other plan steps. If
the step's changes themselves need multiple independent commits, explain why
and ask the user to revise the plan or explicitly authorize that split before
proceeding.

Then present an interactive decision with this format:

```text Proposed commit: <commit message>

How to verify: <short manual or automated verification> ```

For a commit-appropriate step, provide exactly these primary actions:

- `Commit and start next step`
- `Fix based on feedback`
- `Just commit`

`Fix based on feedback` must collect the user's feedback, apply only feedback
relevant to the active step, rerun the relevant checks, update the plan file,
and present the same decision again.

`Commit and start next step` requires explicit approval of the displayed
commit. Create only that approved commit, update the plan file with its
identifier and the completed state, then begin the next numbered step.

`Just commit` requires explicit approval of the displayed commit. Create only
that approved commit, update the plan file with its identifier and the
completed state, then stop before starting another step.

Never commit without the user's explicit selection of one of the two commit
actions for the exact displayed proposal.

If no commit is appropriate, or the directory is not a Git repository, offer
equivalent actions instead:

- `Accept and start next step`
- `Fix based on feedback`
- `Accept and stop`

Update the plan file after every acceptance, commit, block, or significant
discrepancy. Stop when requested, when the plan is complete, or when the next
step requires missing user input.
