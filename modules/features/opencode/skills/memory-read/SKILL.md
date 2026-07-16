---
name: memory-read
description: Recall relevant memory.
---

# Memory Read

Use proactively when prior preferences or workspace decisions may help.

Memory root: `@memory`

- Global contexts: `@memory/global/<name>.md`
- Workspace context: `@memory/workspaces/<sha256(realpath($PWD))>.md`

List candidate files, then call `question` once with a context picker and a
confirm/cancel question. Offer at most four files, prioritizing the current
workspace context, plus a custom exact filename. Read only after confirmation.
If a custom filename does not exist, stop and say so.
