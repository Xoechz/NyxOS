# The system config base for OfficePC
{ pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/kde.nix
      ../../modules/steam.nix
      ../../modules/nvidia.nix
    ];

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub =
    {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;
      extraEntries = "
        menuentry \"Windows\" --class windows --class os {\n
          insmod ntfs\n
          search --no-floppy --set=root --fs-uuid C236-4D6C\n
          chainloader /efi/Microsoft/Boot/bootmgfw.efi\n
        }";
    };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/5939832d-c16a-4b0d-bf9c-fa07d41fd538";
      fsType = "ext4";
    };

  fileSystems."/run/media/fred/100GB-SSD" =
    {
      device = "/dev/disk/by-uuid/2b788cd1-fa01-45ee-bf76-6c396e06015f";
      fsType = "ext4";
    };

  networking.hostName = "OfficePC";

  # Enable networking
  networking.networkmanager.enable = true;

  # user setup
  users.users = {
    fred = {
      isNormalUser = true;
      description = "Fred";
      # lpadmin is needed for printer setup
      extraGroups = [ "networkmanager" "wheel" "lpadmin" ];
    };
    gerhard = {
      isNormalUser = true;
      description = "Gerhard";
      # lpadmin is needed for printer setup
      extraGroups = [ "networkmanager" "wheel" "lpadmin" ];
    };
  };

  # enable flakes and new nix commands
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "fred" "gerhard" "nixremote" ];
  };

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  programs.chromium.enable = true;

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  environment.systemPackages = with pkgs; [
    gnome-software
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "de_AT.UTF-8";

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
    LANGUAGE = "de_AT.UTF-8";
    LANG = "de_AT.UTF-8";
    LC_ALL = "de_AT.UTF-8";
  };

  system.stateVersion = "24.05";
}
