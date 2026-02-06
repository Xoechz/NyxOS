# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "NyxOS";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    betterfox-nix.url = "github:HeitorAugustoLN/betterfox-nix";
    catppuccin.url = "github:catppuccin/nix";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager.url = "github:nix-community/home-manager";
    import-tree.url = "github:vic/import-tree";
    nix-auto-follow = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:fzakaria/nix-auto-follow";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-output-monitor.url = "github:maralorn/nix-output-monitor";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    plasma-manager.url = "github:nix-community/plasma-manager";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    systems.url = "github:nix-systems/default";
  };

}
