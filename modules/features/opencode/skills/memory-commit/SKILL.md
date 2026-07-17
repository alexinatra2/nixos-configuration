---
name: memory-commit
description: Save durable memory.
---

# Memory Commit

Use proactively for durable preferences, decisions, and workspace facts.

Memory root: `@memory`

- Global contexts: `@memory/global/<name>.md`
- Workspace context: `@memory/workspaces/<sha256(realpath($PWD))>.md`

List candidate files, then call `question` once with a context picker. Offer at
most three files, prioritizing the current workspace context, plus `New global`
and `New workspace`. A custom answer names a new global context. Create a
workspace file only when absent. After selection, write one concise,
deduplicated Markdown entry.
