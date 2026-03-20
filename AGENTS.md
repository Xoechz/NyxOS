# NyxOS — Agent Instructions

NyxOS is a modular NixOS system configuration using the **Dendritic Nix Pattern**
(via `flake-parts` + `import-tree`). All configuration is written in pure Nix.
There is no TypeScript, Rust, Python, or other language source code in this repo.

---

## Reference Documentation

- NixOS Wiki: https://nixos.wiki/wiki/NixOS
- Dendritic Pattern Overview: https://dendrix.oeiuwq.com/Dendritic.html
- Dendritic Design Guide: https://github.com/Doc-Steve/dendritic-design-with-flake-parts
- Niri Flake Docs: https://github.com/sodiboo/niri-flake/blob/main/docs.md
- Niri NixOS Wiki: https://wiki.nixos.org/wiki/Niri
- Niri Example Config: https://github.com/sodiboo/system/blob/main/personal/niri.mod.nix
- DankMaterialShell (DMS) GitHub: https://github.com/AvengeMedia/DankMaterialShell
- DMS Docs: https://danklinux.com/docs
- DMS NixOS Flake Guide: https://danklinux.com/docs/dankmaterialshell/nixos-flake
- DMS Example Config: https://gitlab.com/theblackdon/donix

---

## Repository Layout

```
flake.nix          # Auto-generated — NEVER edit directly
flake.lock         # Pinned input hashes
modules/           # All NixOS + Home Manager topic modules
  dendritic.nix    # Flake metadata (description, systems)
  hosts/           # Per-machine configurations (eliasPC, eliasLaptop, fredPC, nixPi)
  *.nix            # Topic modules (apps, browser, desktop, dev, kde, niri, …)
templates/         # Starter dev-shell flake templates
workspaces/        # VS Code .code-workspace files
dms/               # DankMaterialShell theme.json
certs/             # Dev TLS certificates
images/            # Wallpapers and screenshots
```

---

## Build & Apply Commands

> `flake.nix` is auto-generated. To add a new flake input, declare it inside
> the relevant module's `flake-file.inputs` block (see Module Structure below),
> then run `regenerate`.

| Command | Purpose |
|---------|---------|
| `rebuild` | Apply current config to the running system (`nh os switch`) |
| `update` | Rebuild after updating all flake inputs (`nh os switch -u`) |
| `update-lock` | Update `flake.lock` only (`nix flake update`) |
| `regenerate` | Re-generate `flake.nix` from module declarations (`nix run ~/NyxOS#write-flake`) |
| `cleanup` | Optimise store and remove old generations |
| `full-rebuild` | `git pull && rebuild` |
| `full-update` | `git pull && update` |

### Build a specific host without switching

```bash
nix build .#nixosConfigurations.EliasPC.config.system.build.toplevel
nix build .#nixosConfigurations.EliasLaptop.config.system.build.toplevel
nix build .#nixosConfigurations.FredPC.config.system.build.toplevel
nix build .#nixosConfigurations.NixPi.config.system.build.toplevel
```

### Remote deployment

```bash
deploy-to-pi
deploy-to-fredPC
deploy-to-eliasPC
deploy-to-eliasLaptop
```

---

## Validation & "Testing"

There is no traditional test suite. The Nix equivalents are:

```bash
# Validate all configurations evaluate without errors (fastest check)
nix flake check

# Dry-run build a specific host (catches evaluation + build errors, no activation)
nix build .#nixosConfigurations.<HostName>.config.system.build.toplevel --dry-run

# "Single test" equivalent — evaluate one host's config attribute
nix eval .#nixosConfigurations.EliasPC.config.system.build.toplevel
```

---

## Formatting & Linting

```bash
nixpkgs-fmt <file>.nix     # Format a single file
nixpkgs-fmt .              # Format all .nix files recursively
```

- `nixd` is the Nix LSP (language server) — available system-wide.
- There is no CI lint step configured; run `nixpkgs-fmt` manually before committing.
- `nix flake check` also catches evaluation-time type errors.

---

## Module Structure

Every topic file in `modules/` follows this exact pattern:

```nix
{ inputs, ... }:          # Use { ... }: when no inputs are needed
{
  # 1. Declare any NEW flake inputs this module introduces
  flake-file.inputs = {
    some-input.url = "github:owner/repo";
    some-input.inputs.nixpkgs.follows = "nixpkgs";
  };

  # 2. NixOS system module
  # System Module <moduleName>: <one-line description>
  flake.modules.nixos.<moduleName> = { pkgs, lib, config, system, ... }: {
    # NixOS options
  };

  # 3. Home Manager module (when needed)
  # Home Module <moduleName>: <one-line description>
  flake.modules.homeManager.<moduleName> = { pkgs, lib, config, ... }: {
    # home-manager options
  };
}
```

Host files in `modules/hosts/` declare `flake.nixosConfigurations.<HostName>`
and import topic modules using `with inputs.self.modules.nixos; [...]`.

---

## Naming Conventions

| Item | Convention | Examples |
|------|-----------|---------|
| Module files | `camelCase.nix` | `apps.nix`, `desktop.nix`, `eliasPC.nix` |
| NixOS module names | `camelCase` | `baseSettings`, `optimizationsPC`, `basicCatppuccin` |
| `nixosConfigurations` keys | `PascalCase` | `EliasPC`, `EliasLaptop`, `FredPC`, `NixPi` |
| Nix local variables (`let`) | `camelCase` | `catppuccinIcons`, `isMobile` |
| NixOS option paths | follow upstream | `boot.loader.grub.device`, `services.openssh.enable` |

---

## Code Style

### `let` bindings

Declare local variables before the attribute set body:

```nix
let
  myPackage = pkgs.somePackage.override { option = true; };
in
{
  environment.systemPackages = [ myPackage ];
}
```

### `with` for package lists

```nix
environment.systemPackages = with pkgs; [
  package1
  package2
];
```

### Conditional values

Use `lib.mkIf` for conditional options and `lib.mkDefault` / `lib.mkForce`
to express priority:

```nix
boot.binfmt.emulatedSystems = lib.mkIf (system == "x86_64-linux") [ "aarch64-linux" ];
gtk.iconTheme               = lib.mkForce { name = "Papirus-Dark"; package = ...; };
boot.loader.grub.device     = lib.mkDefault "nodev";
```

### Imports in host files

```nix
imports = with inputs.self.modules.nixos; [
  languageEn
  fonts
  baseDesktop
  catppuccin
];
```

### `specialArgs` for cross-module data

Pass non-standard values (e.g. `system`, `swapSize`, `users`, `isMobile`,
`pkgs-stable`) through `specialArgs` / `extraSpecialArgs` rather than options:

```nix
specialArgs = { system; pkgs-stable = ...; swapSize = 8; users = [ "elias" ]; };
```

### Comments

Each module definition **must** have a preceding comment in this exact format:

```nix
# System Module <moduleName>: <description matching README>
# Home Module <moduleName>: <description matching README>
```

**Every module defined in `modules/` must also be listed in `README.md`** under
the appropriate "System Modules" or "Home Modules" section. The description in
the comment and the README must match exactly. When you add, rename, or
significantly change a module, update both the in-file comment and `README.md`
in the same change.

### Path interpolation

Use `config.home.homeDirectory` (not hardcoded `~` or `/home/elias`) for
portability across users:

```nix
shellAliases.rebuild = "nh os switch ${config.home.homeDirectory}/NyxOS";
```

---

## Key Constraints

- **Never edit `flake.nix` directly.** It is auto-generated by
  `nix run ~/NyxOS#write-flake` from `flake-file.inputs` declarations in each
  module. Add new inputs only inside a module's `flake-file.inputs` block.
- **`nixpkgs` input follows `nixpkgs`** — all new flake inputs should set
  `<input>.inputs.nixpkgs.follows = "nixpkgs"` to avoid duplicate nixpkgs
  instances in the store.
- **Unstable by default.** The primary nixpkgs is `nixos-unstable`. Use
  `pkgs-stable` (passed via `specialArgs`) only for packages that break on
  unstable (e.g. libreoffice, kdenlive).
- **Multi-architecture.** Supported systems are `x86_64-linux` and
  `aarch64-linux`. Use `lib.mkIf (system == "x86_64-linux") { ... }` for
  arch-specific config.
