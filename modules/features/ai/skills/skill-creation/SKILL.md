---
name: skill-creation
description: Use when creating or revising a SKILL.md. Draft, approve, and validate the skill.
---

# Skill Creation

## Discover

Inspect active paths, instructions, and similar skills. Confirm name, path, and
scope. Ask only about material ambiguity.

Clone relevant repos into a temporary directory with `clone_repository` to
familiarize with structure, docs, and conventions. Rely on native `/tmp` cleanup.

## Approve

Print the exact proposed `SKILL.md` once immediately before `question`. Do not
summarize or repeat it. Offer:

- `Approve draft`
- `Stop`

Treat free text as revision feedback. Do not edit without approval.

## Draft

- Use `<skill-path>/<name>/SKILL.md`.
- Match the folder name and lowercase hyphenated frontmatter `name`.
- Keep the description concrete.
- Do not add revise, fix, or custom-answer choices; free text is the sole
  revision path.
- Prefer terse instructions.

## Validate

Check path, frontmatter, name, description, overlap, final diff, and formatting.
Report the file and result.
