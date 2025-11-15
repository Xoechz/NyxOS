# The system config base for EliasPC
{ pkgs, ... }:

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

  # user setup
  users.users.elias = {
    isNormalUser = true;
    description = "Elias";
    # lpadmin is needed for printer setup
    extraGroups = [ "networkmanager" "wheel" "lpadmin" ];
  };

  # enable flakes and new nix commands
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "elias" "nixremote" ];
  };

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  users.users.elias.shell = pkgs.zsh;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
    LANGUAGE = "en_GB.UTF-8";
    LANG = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
  };

  system.stateVersion = "24.05";
}
