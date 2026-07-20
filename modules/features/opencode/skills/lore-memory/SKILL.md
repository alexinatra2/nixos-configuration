---
name: lore-memory
description: Retrieve Lore for possible prior project knowledge and evaluate durable facts after substantive repository work.
---

# Lore Memory

Use Lore as the only active memory system.

## Retrieve

Call `lore_retrieve` before broad searching or asking the user when a request
may depend on a prior decision, preference, convention, deployment fact, or
repository fact not established in context.

Use repository scope by default. Use global scope only for cross-repository
facts. Current repository evidence overrides conflicting memory.

## Evaluate

Before the final response after substantive work, keep a candidate only if it
is verified, novel, durable, future-useful, atomic, and not readily
discoverable from the repository.

Exclude transient status, guesses, secrets, personal data, generated values,
logs, and code-derived details. Retrieve related facts to detect duplicates and
conflicts. If nothing qualifies, do not ask about memory.

Use repository scope by default. Use global scope only when the fact must be
available across repositories in the same access group.

## Approve And Write

Before mutation, use one `question` call showing each exact subject, statement,
scope, and action. Let the user approve, revise, or skip each candidate.

After approval, call `lore_remember` for new knowledge or `lore_supersede` with
the obsolete fact ID. Write only approved content. Never fall back to Markdown
memory.
