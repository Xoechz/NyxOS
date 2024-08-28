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
      ../../modules/dev.nix
      ../../modules/styling.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "EliasPC";

  # Enable networking
  networking.networkmanager.enable = true;

  system.stateVersion = "24.05";
}
