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
      ../../modules/styling.nix
      ../../modules/language_de_at.nix
    ];

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    extraEntries = ''
      menuentry "UEFI Firmware Settings" --class efi {
        fwsetup
      }
    '';
  };

  fileSystems."/run/media/OldWindows" = {
    device = "/dev/disk/by-uuid/A60E66E70E66B04B";
    fsType = "ntfs";
  };

  fileSystems."/run/media/Windows" = {
    device = "/dev/disk/by-uuid/A48C4D438C4D10EA";
    fsType = "ntfs";
  };

  networking.hostName = "FredPC";

  # Enable networking
  networking.networkmanager.enable = true;

  # user setup
  users.users = {
    fred = {
      isNormalUser = true;
      description = "Fred";
      # lpadmin is needed for printer setup
      extraGroups = [ "networkmanager" "wheel" "lpadmin" "video" ];
    };
    gerhard = {
      isNormalUser = true;
      description = "Gerhard";
      # lpadmin is needed for printer setup
      extraGroups = [ "networkmanager" "wheel" "lpadmin" "video" ];
    };
  };

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  environment.systemPackages = with pkgs; [
    kdePackages.discover
    (chromium.override {
      commandLineArgs = [ "--disable-gpu" ];
    })
  ];

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  system.stateVersion = "25.05";
}
