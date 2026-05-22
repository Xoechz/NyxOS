---
name: cavekit-build
description: Execute next task from SPEC.md. Mark wip → impl → test → mark done or backprop. Triggers= "/ck:build", "build next task", "execute spec".
compatibility: opencode
---

# cavekit build skill

If task ids specified, execute those. Else execute next `.` task in §T. One task per run.

## Steps

1. Read `SPEC.md`
2. Select specified task(s) or first §T `.` row
3. Mark `~` (wip)
4. Plan against §V invariants + §I interfaces
5. Implement
6. Verify build + tests pass
7. Mark `x` (done)
8. On failure, backprop: append §B row and add/strengthen §V invariant

## Backprop Protocol (on failure)

1. Find root cause
2. Append §B row: `B<n>|<date>|<cause>|<fix>`
3. Add recurrence-catching §V invariant: `V<n>: <testable condition>`
4. Fix code
5. Re-run until green
6. Mark task `x`

## Constraints

- Keep task order; no skipping
- Never mark `x` before build and tests pass
- Backprop §V invariants must be testable
- If ambiguous, ask; do not guess
