# NyxOS — Agent Instructions

NyxOS is a modular NixOS system configuration using the **Dendritic Nix Pattern**
(via `flake-parts` + `import-tree`). All configuration is written in pure Nix.
There is no TypeScript, Rust, Python, or other language source code in this repo.

---

## MCP Servers

The following MCP servers are available to all agents in this session:

| Server | Best used for |
|--------|--------------|
| `context7` | Library and framework documentation — look up nixpkgs package attributes, NixOS module options, Home Manager options, and upstream project APIs |
| `mcp-nixos` | NixOS/Home Manager option resolution and package search directly against the Nix ecosystem — prefer this over context7 for NixOS/HM option queries |
| `microsoft-learn` | Official Microsoft/Azure documentation — .NET APIs, C# language reference, Azure services |

**When to use which:**

- Querying a NixOS or Home Manager option (e.g. `services.openssh.*`, `programs.git.*`) → use `mcp-nixos`
- Looking up a nixpkgs package's attributes, version, or derivation details → use `mcp-nixos`
- Looking up upstream library docs, API references, or non-NixOS framework documentation → use `context7`
- Looking up .NET/C# API docs, Azure services, or Microsoft platform docs → use `microsoft-learn`

---

## Hosts

| Key | Arch | Notes |
|-----|------|-------|
| `EliasPC` | x86_64-linux | Intel CPU + AMD GPU, desktop, distributed-builder |
| `EliasLaptop` | x86_64-linux | Intel CPU + NVIDIA GPU, mobile (`isMobile = true`) |
| `FredPC` | x86_64-linux | KDE, German locale |
| `NixPi` | aarch64-linux | Raspberry Pi server, no desktop |

---

## Reference Documentation

- NixOS Wiki: <https://nixos.wiki/wiki/NixOS>
- Dendritic Pattern Overview: <https://dendrix.oeiuwq.com/Dendritic.html>
- Dendritic Design Guide: <https://github.com/Doc-Steve/dendritic-design-with-flake-parts>
- Niri Flake Docs: <https://github.com/sodiboo/niri-flake/blob/main/docs.md>
- Niri NixOS Wiki: <https://wiki.nixos.org/wiki/Niri>
- Niri Example Config: <https://github.com/sodiboo/system/blob/main/personal/niri.mod.nix>
- DankMaterialShell (DMS) GitHub: <https://github.com/AvengeMedia/DankMaterialShell>
- DMS Docs: <https://danklinux.com/docs>
- DMS NixOS Flake Guide: <https://danklinux.com/docs/dankmaterialshell/nixos-flake>
- DMS Example Config: <https://gitlab.com/theblackdon/donix>

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
packages/          # Self packaged programmes like aspire
workspaces/        # VS Code .code-workspace files
resources/         # Static files referenced by config (e.g. DMS , certs)
images/            # Wallpapers and screenshots
```

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
  # System Module <module-name>: <one-line description>
  flake.modules.nixos.<module-name> = { pkgs, lib, config, system, ... }: {
    # NixOS options
  };

  # 3. Home Manager module (when needed)
  # Home Module <module-name>: <one-line description>
  flake.modules.homeManager.<module-name> = { pkgs, lib, config, ... }: {
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
| NixOS module names | `kebab-case` | `base-settings`, `optimizations-pc`, `basic-catppuccin` |
| Home Manager module names | `kebab-case` | `opencode-dotnet`, `plasma-manager`, `gui-utilities` |
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
  language-en
  fonts
  base-desktop
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
# System Module <module-name>: <description matching README>
# Home Module <module-name>: <description matching README>
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
- **Unstable by default.** Primary nixpkgs is `nixos-unstable`. `pkgs-stable` pins `nixos-25.11` (declared in `modules/dendritic.nix`). Use `pkgs-stable` only for packages that break on unstable (e.g. libreoffice, kdenlive).
- **Multi-architecture.** Supported systems: `x86_64-linux`, `aarch64-linux`. Guard arch-specific config with `lib.mkIf (system == "x86_64-linux") { ... }`.
- **Remote building.** When EliasPC unavailable and task is resource-intensive, ask whether to wake it via Cloudflare WARP tunnel + WoL magic packet.
