---
name: delegate
description: Route tasks of different domains to correct tier. Never execute directly first.
compatibility: opencode
---

# Task Delegation

Classify by risk/size, delegate to correct tier. Do not execute directly first.

## Tiers

| Tier   | Model                      | When to use                                    |
|--------|----------------------------|------------------------------------------------|
| lite   | gpt-5-mini                 | up to 3 files, simple low-risk edits           |
| medium | claude-haiku-4.5           | main body: simple adds/refactors across projects |
| heavy  | gpt-5.3-codex              | complex cross-project work, incl security      |
| max    | claude-sonnet-4.6          | critical/last-resort or explicitly requested   |

## Classification

Use blast radius first, then complexity.

**lite**
- up to 3 files, simple edits, usually <= 60 changed lines
- no API/schema/interface behavior change
- examples: rename symbol, add import/using, typo, literal/config tweak, tiny guard

**medium**
- simple additions/refactors across projects
- usually 3-10 files, cohesive feature/fix, primary work tier
- behavior mostly local, verification still straightforward
- examples: add endpoint option + DTO + service + tests across projects

**heavy**
- complex work across projects/subsystems
- deep runtime debugging, substantial refactor, architecture-sensitive and security work
- examples: auth hardening across services, complex refactor with dependency strategy changes

**max**
- only when situation is critical, blocked at lower tiers, or user explicitly requests
- highest-complexity architecture/incident work with broad uncertainty
- examples: severe production incident triage, failing multi-attempt cross-system redesign

Escalate to `max` when any are true:
- user explicitly asks for max tier
- heavy produced repeated failed attempts / no stable path
- critical incident with high ambiguity and broad impact

## Routing

1. Classify task using rules above
2. Split into subtasks if needed, classify each
3. Execute → `@<domain>-<tier>`
4. Default most non-trivial work to `medium`; use `heavy` for complex cross-project/security work
5. Escalate to `max` only on explicit request or critical/blocked conditions
5. Do not auto-downgrade after escalation unless user asks

## Decision Ladder

1. Simple low-risk edits, up to 3 files, no contract/behavior shift?
	- Yes -> `lite`
	- No -> step 2
2. Mainline adds/refactors across projects, still straightforward to verify?
	- Yes -> `medium`
	- No -> step 3
3. Complex cross-project/debug/security-sensitive implementation?
	- Yes -> `heavy`
	- No -> step 4
4. Crisis-level ambiguity, repeated heavy failure, or explicit max request?
	- Yes -> `max`
	- No -> `heavy`

## Routing Examples

- Rename variable in one C# file -> `@dotnet-lite`
- Add endpoint option + DTO + service + tests across projects -> `@dotnet-medium`
- Debug 401 across middleware + service + auth policy and fix security flow -> `@dotnet-heavy`
- Critical outage + repeated failed heavy attempts -> `@dotnet-max`
- Fix typo + key in one YAML file -> `@general-lite`
- Update configs + scripts across projects as one feature -> `@general-medium`
- Complex cross-project migration with security implications -> `@general-heavy`
- Crisis-level cross-system failure, explicit max request -> `@general-max`

## Domains

- **general** → `@general-lite` / `@general-medium` / `@general-heavy` / `@general-max`
- **dotnet** → `@dotnet-lite` / `@dotnet-medium` / `@dotnet-heavy` / `@dotnet-max`

## After completion

Invoke domain review agent if critical dotnet change → `@dotnet-review`

## Default agent rule

Only plan, route, and manage workers
