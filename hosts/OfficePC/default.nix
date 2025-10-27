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

  fileSystems."/run/media/fred/4TB-HDD" =
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

  system.stateVersion = "24.05";
}
