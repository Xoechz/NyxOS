# The system config base for FredPC
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
      ../../modules/language_de_at.nix
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

  # put file systems here if needed

  networking.hostName = "FredPC";

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
