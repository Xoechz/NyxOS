---
description: Run statix check and explain any warnings or errors
agent: build
---

Run `statix check` in `~/NyxOS` and report results.

!`cd ~/NyxOS && statix check 2>&1`

If warnings/errors:
1. Identify which file and line
2. Explain what lint rule means and why it matters
3. Show corrected Nix snippet per finding

All pass: confirm lint-clean.
