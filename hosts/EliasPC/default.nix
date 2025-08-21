# The system config base for EliasPC
{ config, ... }:

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

  fileSystems."/run/media/elias/4TB-HDD" =
    {
      device = "/dev/disk/by-uuid/5939832d-c16a-4b0d-bf9c-fa07d41fd538";
      fsType = "ext4";
    };

  fileSystems."/run/media/elias/100GB-SSD" =
    {
      device = "/dev/disk/by-uuid/2b788cd1-fa01-45ee-bf76-6c396e06015f";
      fsType = "ext4";
    };

  networking.hostName = "EliasPC";

  # Enable networking
  networking.networkmanager.enable = true;

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  system.stateVersion = "24.05";
}
