{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  # Define flake attributes on any flake-parts module:
  flake-file = {
    description = "NyxOS";
    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    };
  };

  # set flake.systems
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
