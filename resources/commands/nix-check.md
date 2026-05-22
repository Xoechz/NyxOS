---
description: Run nix flake check and explain any errors
agent: build
---

Run `nix flake check` in `~/NyxOS` and report results.

!`cd ~/NyxOS && nix flake check 2>&1`

If errors:
1. Identify which module or host caused each
2. Explain what error means
3. Suggest fix with corrected Nix snippet

All pass: confirm cleanly.
