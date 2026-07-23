---
name: lore-memory
description: Retrieve Lore for possible prior project knowledge and evaluate durable facts after substantive repository work.
---

# Lore Memory

Use Lore as the only memory system.

## Retrieve

Call `lore_retrieve` before broad searching or asking when work may depend on
an unstated prior decision, preference, convention, deployment fact, or
repository fact.

Use repository scope by default. Current repository evidence wins.

## Evaluate

After substantive work, keep only verified, novel, durable, useful, atomic
facts not readily discoverable from the repository.

Exclude transient state, guesses, secrets, personal data, generated values,
logs, and code-derived details. Check for duplicates and conflicts. If nothing
qualifies, do not ask.

## Write

Before mutation, show each exact subject, statement, scope, and action in one
`question`. Offer approval and skip; treat free text as revision feedback.

Write only approved facts with `lore_remember` or `lore_supersede`. Never use
Markdown memory.
