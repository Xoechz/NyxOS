# Upstreaming `aspire-cli` to nixpkgs

After local testing on both `x86_64-linux` and `aarch64-linux`, the next step is contributing to nixpkgs.

## Checklist

- [ ] Builds on `x86_64-linux` (`nix build .#aspire-cli`)
- [ ] Builds on `aarch64-linux` (cross-build or native)
- [ ] `aspire doctor` runs and reports no issues
- [ ] `aspire new` creates a project
- [ ] `aspire --version` outputs the correct version

## Preparing the PR

1. **Fork** nixpkgs and clone it

   ```bash
   git clone https://github.com/<your-username>/nixpkgs
   cd nixpkgs
   git remote add upstream https://github.com/NixOS/nixpkgs
   git fetch upstream
   git checkout -b aspire-cli-13.4.6
   ```

2. **Create the package** at `pkgs/by-name/as/aspire-cli/package.nix`

   nixpkgs uses `pkgs/by-name` for new packages. The directory name is the first 2 chars of the pname.

3. **Format** with `nixpkgs-fmt`:

   ```bash
   nixpkgs-fmt pkgs/by-name/as/aspire-cli/package.nix
   ```

4. **Generate `deps.nix` lockfile** via `fetch-deps` passthru:

   ```bash
   nix build nixpkgs#aspire-cli.fetch-deps
   ./result
   ```

5. **Run nixpkgs checks**:

   ```bash
   nix build .#aspire-cli
   nix flake check -L
   ```

## Key differences from NyxOS version

| Aspect | NyxOS | nixpkgs |
|--------|-------|---------|
| SDK pin | `dotnetCorePackages.sdk_10_0` | `dotnetCorePackages.sdk_10_0` (same) |
| Overlay | `nixpkgs.overlays` | Not needed (direct package) |
| deps format | `deps.json` | `deps.nix` (or JSON — match surrounding packages) |

## PR description template

```markdown
aspire-cli: init at 13.4.6

The Aspire CLI creates, runs, and manages .NET Aspire
distributed applications. This is a Native AOT build
so it needs no runtime dependency.

Tested on x86_64-linux:
- `aspire doctor` passes
- `aspire new` generates a project
```

## Useful links

- [nixpkgs manual: Contributing](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [nixpkgs manual: .NET](https://nixos.org/manual/nixpkgs/stable/#dotnet)
- [Aspire releases](https://github.com/microsoft/aspire/releases)
- [Aspire CLI NuGet](https://www.nuget.org/packages/Aspire.Cli)