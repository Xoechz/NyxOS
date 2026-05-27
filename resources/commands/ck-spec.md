---
description: Create or amend SPEC.md using cavekit spec-driven development
agent: manager
---

Load `cavekit` skill and help user create or amend SPEC.md.

Parse request:
- "new" or no SPEC.md exists → `/ck:spec new`
- "amend §<S>" → edit that section
- "bug <description>" → append §B row + new §V invariant

Follow cavekit skill format exactly. Write SPEC.md to repo root.
