---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
---

# Handoff

## When to use this skill

When the user wants to handoff a subtask to another agent, use this skill to create a handoff document that summarizes the current conversation and provides context for the next agent.

NEVER EXECUTE IF NOT EXPLICITLY ASKED. 

## Parameters

- What is this handoff about? What subtask is being handed off?

## Steps

- Write a handoff document summarising the current conversation so a fresh agent can continue the work.
  - Create a new file in the `~/.copilot/work/` directory named `handoff-<short-description>.md` where `<short-description>` is a short description of the work being handed off.
  - Include a "suggested skills" section in the document, which suggests skills that the agent should invoke. Do not suggest agents or subagents, only skills. Include the skill name and a brief description of what the skill does.
  - Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
  - Redact any sensitive information, such as API keys, passwords, or personally identifiable information.
  - Tailor the handoff document to the subtask being handed off.
  - Do not include build or test execution steps in the handoff document. Only the developer builds and runs tests. The handoff document only covers implementation tasks. Unit tests are part of the implementation tasks, but the handoff document does not include running them.
