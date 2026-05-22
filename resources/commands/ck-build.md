---
description: Execute next task from SPEC.md using cavekit build loop
agent: build
---

Load `cavekit-build` skill and execute next todo task from SPEC.md.

!`cat SPEC.md 2>/dev/null || echo "SPEC.md not found — run /ck-spec first"`

Follow build skill protocol exactly. Backprop failures into §B and §V before marking done.
