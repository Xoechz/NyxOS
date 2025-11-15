# The system config base for EliasLaptop
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
      useOSProber = false;
      extraEntries = "
        menuentry \"Windows\" --class windows --class os {\n
          insmod ntfs\n
          search --no-floppy --set=root --fs-uuid C236-4D6C\n
          chainloader /efi/Microsoft/Boot/bootmgfw.efi\n
        }";
    };

  networking.hostName = "EliasLaptop";

  # Enable networking
  networking.networkmanager.enable = true;

  # enables support for Bluetooth
  hardware.bluetooth.enable = true;
  # powers up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = true;
  # allow reading device charge
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

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
    size = 18 * 1024; # 18GB
    randomEncryption.enable = true;
  }];

  hardware.nvidia.prime = {
    reverseSync.enable = true;
    # Enable if using an external GPU
    allowExternalGpu = false;

    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };

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
