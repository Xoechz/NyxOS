# The system config base for EliasPC
{ ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/kde.nix
      ../../modules/steam.nix
      ../../modules/amd.nix
      ../../modules/dev.nix
      ../../modules/styling.nix
    ];

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub =
    {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };

  networking.hostName = "EliasPC";

  # Enable networking
  networking.networkmanager.enable = true;

  system.stateVersion = "24.05";
}
