---
name: handback
description: Compact the current conversation into a handback document to give back to the session that created the handoff.
---

# Handoff

## When to use this skill

When the user wants to return a subtask to the session that created the handoff. Ask the user if he wants to use this skill at the end of the handoff session.

## Parameters

- Handoff document: the name of the handoff document to return to the session that created the handoff.

## Steps

- Write a handback document documenting what was done in the handoff session.
  - Create a new file in the `~/.copilot/work/` directory named `handback-<short-description>.md` where `<short-description>` is the same as the handoff document being returned.
  - Redact any sensitive information, such as API keys, passwords, or personally identifiable information.
  - Base the handback document on the handoff document, but do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
