---
name: summarize-status
description: Use when the user wants a plain-language summary of the repository's Git working tree and branch state.
---

# Summarize Status

Report Git state readably: what is in flight and what it means, without raw
output and without changing anything.

## Inspect

Read only. Run these in the repository root:

- `git status --porcelain=v1 -b` — working tree and branch tracking.
- `git branch -vv` — local branches and their upstreams.
- `git worktree list --porcelain` — live worktrees.
- `git log --oneline -5` — recent history.
- `git diff --stat <upstream>..HEAD` — only when ahead of upstream.

## Report

Three sections, plain language, no jargon without a short explanation:

- **Headline** — clean or dirty, N ahead / N behind, what is in flight:
  uncommitted, staged, unpushed, or unreviewed work.
- **Changes** — one line per theme describing what the pending work actually
  does (e.g. "switched the AI memory backend from lore to OpenViking").
  Group trivial or related changes together.
- **Flags** — only anomalies: stale feature branches, live or detached
  worktrees, staged secrets, missing upstreams.

Never modify files, stage, commit, or push. Show raw diffs only on request.
