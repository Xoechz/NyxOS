---
description: Read-only drift report — check code against SPEC.md invariants and interfaces
agent: manager
---

Load `cavekit-check` skill and report drift.

!`cat SPEC.md 2>/dev/null || echo "SPEC.md not found — run /ck-spec first"`

Report all §V, §I, and §T violations. No file changes.
