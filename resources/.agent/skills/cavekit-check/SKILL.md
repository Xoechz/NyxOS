---
name: cavekit-check
description: Read-only drift report. Check code against SPEC.md §V §I §T. Triggers= "/ck:check", "check spec", "drift report".
compatibility: opencode
---

# cavekit check skill

Read-only. No edits. Report drift between `SPEC.md` and codebase.

## Steps

1. Read `SPEC.md`
2. Check §V invariants
3. Check §I interfaces against implementation
4. Check §T `x` tasks are truly complete
5. Report violations grouped by section

## Output Format

```
§V violations:
  V2: token expiry check uses < not ≤ (src/auth/middleware.ts:42)

§I violations:
  api: POST /x not implemented (no route found)

§T drift:
  T3: marked x but handler missing null check (§V.1)

Clean: §G, §C
```

If clean: `SPEC.md: clean. No drift detected.`
