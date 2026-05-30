---
name: nix-module
description: Conventions for writing NixOS and Home Manager modules in the NyxOS Dendritic flake-parts repository. Load before touching any .nix file.
compatibility: opencode
---

## File layout

- Topic modules: `modules/<camelCase>.nix`
- Host configs: `modules/hosts/<camelCase>.nix`
- `flake.nix` is **auto-generated** — never edit. Add inputs only in `flake-file.inputs` blocks.
- Module file signature: `{ inputs, ... }:` (use `{ ... }:` when no inputs needed)

## Declaring flake inputs

```nix
flake-file.inputs = {
  some-input.url = "github:owner/repo";
  some-input.inputs.nixpkgs.follows = "nixpkgs";  # always required
};
```

After adding/changing inputs, run `regenerate` (`nix run ~/NyxOS#write-flake`).

## Module registration

- System modules: `flake.modules.nixos.<kebab-case>`
- Home Manager modules: `flake.modules.homeManager.<kebab-case>`
- Each definition needs a preceding comment:
  ```nix
  # System Module <name>: <description>
  # Home Module <name>: <description>
  ```
- Description must exactly match the README.md entry. Update both together.

## Hosts

Declared in `modules/hosts/<camelCase>.nix` as `flake.nixosConfigurations.<PascalCase>`.

| Host | Arch | Notes |
|------|------|-------|
| EliasPC | x86_64-linux | Intel + AMD GPU, desktop, distributed-builder |
| EliasLaptop | x86_64-linux | Intel + NVIDIA GPU, `isMobile = true` |
| FredPC | x86_64-linux | KDE, German locale |
| NixPi | aarch64-linux | Raspberry Pi, no desktop |

## nixpkgs channels

- `pkgs` → `nixos-unstable` (default)
- `pkgs-stable` → `nixos-25.11` (via `specialArgs`; use only for packages that break on unstable, e.g. libreoffice, kdenlive)

## Code style

```nix
# let bindings before attrset body
let myPkg = pkgs.foo.override { bar = true; }; in
{
  environment.systemPackages = with pkgs; [ pkg1 pkg2 ];
  boot.binfmt.emulatedSystems = lib.mkIf (system == "x86_64-linux") [ "aarch64-linux" ];
  some.option = lib.mkDefault "value";
  other.option = lib.mkForce "override";
}
```

- Cross-module data → `specialArgs` / `extraSpecialArgs`, not options
- Paths → `config.home.homeDirectory`, never `/home/elias` or `~`
- Arch-specific → `lib.mkIf (system == "x86_64-linux") { ... }`
- Host imports: `imports = with inputs.self.modules.nixos; [ foo bar ];`

## Naming

| Item | Convention |
|------|-----------|
| Module files | `camelCase.nix` |
| NixOS / HM module names | `kebab-case` |
| `nixosConfigurations` keys | `PascalCase` |
| `let` variables | `camelCase` |

## Validation

```bash
nixpkgs-fmt <file>.nix   # format single file
nixpkgs-fmt .            # format all
```

Do not build or run flake check! Building is reserved for the developer, except when explicitly requested.

Use only the LSP for checking.

## MCP tools

- `mcp-nixos` — NixOS/HM option lookup, package search, nixpkgs attributes. **Prefer this for anything Nix-ecosystem.**
- `context7` — upstream library docs, non-NixOS API references.
