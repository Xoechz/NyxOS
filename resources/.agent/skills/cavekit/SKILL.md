---
name: cavekit
description: 'Spec-driven dev. Create/amend SPEC.md in caveman encoding. Triggers= "write a spec", "update spec", "/ck:spec".'
compatibility: opencode
---

# cavekit spec skill

Maintain one `SPEC.md` at repo root; all cavekit commands use it.

## SPEC.md Format

Use fixed sections in fixed order:

```
# SPEC

## §G GOAL
one line. what code must do.

## §C CONSTRAINTS
- bullet. non-negotiable boundary.
- bullet. tech/lang/lib locked in.

## §I INTERFACES
external surface. what world sees.
- cmd: `foo bar` → stdout JSON
- api: POST /x → 200 {id}
- file: `config.yaml` schema
- env: `FOO_KEY` required

## §V INVARIANTS
numbered. testable. each ! MUST hold.
V1: ∀ req → auth check before handler
V2: token expiry ≤ ⊥ allowed

## §T TASKS
pipe table. ids monotonic (never reused). status: x done / ~ wip / . todo.
id|status|task|cites
T1|.|scaffold repo|-
T2|.|impl §I.api POST /x|V2

## §B BUGS
pipe table. backprop log.
id|date|cause|fix
B1|2026-04-20|token < not ≤|V2
```

## Caveman Encoding

Default for all sections.

- Drop articles/filler/extra auxiliaries when clear.
- Prefer short verbs (`fix`, `add`).
- Fragments allowed.

Keep verbatim: code, paths, identifiers, URLs, numbers, error strings.

Symbols:
- `→` leads to/triggers
- `∴` therefore/fix
- `∀` for all/every
- `!` must
- `⊥` never/forbidden
- `≤` at most / `≥` at least
- `&` and / `|` or

## Commands

- `/ck:spec new`: create `SPEC.md`
- `/ck:spec amend §<S>`: edit one section
- `/ck:spec bug <description>`: append §B row + add recurrence-preventing §V invariant

## Rules

- One root `SPEC.md` per repo
- §T ids monotonic, never reused
- §B append-only (never delete rows)
- If `SPEC.md` > 500 lines, compact old §B rows (do not split files)
