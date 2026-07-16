---
name: skill-creation
description: Use when creating or revising an OpenCode SKILL.md. Inspect conventions, show one exact draft for approval, then validate the approved skill.
---

# Skill Creation

Use only for OpenCode skills. Do not use for agents, commands, plugins, config,
or MCP servers.

## Discover

1. Inspect active skill paths, local instructions, and similar skills.
2. Confirm the target name, path, and scope.
3. Ask only for missing material requirements.

## Propose

Before editing:

1. Print the exact proposed `SKILL.md` once in the response immediately before
   using `question`.
2. Do not summarize or repeat the proposed file.
3. Use `question` with:
   - `Approve draft`
   - `Revise draft`
   - `Stop`

Do not edit without approval.

## Draft

- Use `<skill-path>/<name>/SKILL.md`.
- Match the folder name and lowercase hyphenated frontmatter `name`.
- Keep the description concrete: what it does and when to trigger it.
- Defer wording and terseness rules to the system prompt.
- Example: write `Inspect config.` not `Carefully inspect the relevant
configuration files.`

## Validate

1. Confirm the path, frontmatter, name, and description meet OpenCode
requirements.
2. Check the skill does not overlap an existing skill without a clear boundary.
3. Inspect the final diff and run focused formatting checks.
4. Report the file and validation result.
