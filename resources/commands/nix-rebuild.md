---
description: Dry-run build all NyxOS hosts, summarise what would change
agent: build
---

Dry-run build all four NyxOS hosts, summarise what would be built/changed.

!`cd ~/NyxOS && nix build .#nixosConfigurations.EliasPC.config.system.build.toplevel --dry-run 2>&1`
!`cd ~/NyxOS && nix build .#nixosConfigurations.EliasLaptop.config.system.build.toplevel --dry-run 2>&1`
!`cd ~/NyxOS && nix build .#nixosConfigurations.FredPC.config.system.build.toplevel --dry-run 2>&1`
!`cd ~/NyxOS && nix build .#nixosConfigurations.NixPi.config.system.build.toplevel --dry-run 2>&1`

Per host: list derivations that would be built (not in store) and flag eval errors. All clean: confirm.
