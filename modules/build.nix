# Distributed build configuration - builds on EliasPC only
{ config, lib, ... }:

let
  buildMachines = [
    {
      hostName = "EliasPC";
      system = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 16;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
in
{
  nix = {
    buildMachines = lib.mkIf config.nix.distributedBuilds buildMachines;

    # Centralized nix settings
    settings = {
      # Package repositories
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ] ++ lib.optionals config.nix.distributedBuilds [
        "ssh-ng://EliasPC"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ] ++ lib.optionals config.nix.distributedBuilds [
        "EliasPC:FeMYLAaSK5o419ftDiAxhHs6x3n+tIsEq+LlZif0pg4="
      ];

      # Enable flakes and new nix commands
      experimental-features = [ "nix-command" "flakes" ];

      # Trust nix daemon
      trusted-users = [ "elias" "nixremote" ];

      # Allow builders to use substitutes
      builders-use-substitutes = true;
    };

    # Optimize nix store usage
    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };
}
