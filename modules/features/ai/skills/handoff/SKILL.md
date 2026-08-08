---
name: handoff
description: Bundle workspace and context for handoff to a local model when remote API usage is depleted.
---

# Handoff

## Trigger

When the user reports depleted usage, switched models, or asks to export context
for a local agent.

## Bundle

Call `handoff_bundle`. It returns the path to a `handoff-<timestamp>.tar.gz`
archive in an ephemeral directory.

## Context

Write a three-section summary for the local model:

1. **Work in progress** — what was being done, which files, current state.
2. **Key decisions** — architectural choices, conventions, constraints.
3. **Next steps** — ordered instructions the local model should follow, with
   verification commands.

## Report

```
Archive: <path>
Handoff context:
<the three sections>
```

Note the ephemeral directory is cleaned up on next boot.