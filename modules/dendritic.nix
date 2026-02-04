{ inputs, lib, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.nix-auto-follow
  ];

  # Define flake attributes on any flake-parts module:
  flake-file = {
    description = "NyxOS";
    prune-lock.enable = true;
  };
}
