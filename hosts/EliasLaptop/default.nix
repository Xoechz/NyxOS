# The system config base for EliasLaptop
{ config, ... }:

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
      useOSProber = false; # enable if dual booting
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

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 18 * 1024; # 18GB
    randomEncryption.enable = true;
  }];

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/keys/cache-private.pem";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "cache.eliasLaptop.lan" = {
        locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "http://cache.eliasPC.lan"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.eliasPC.lan:tlg80Kl0He8uCZhANAp1gHA3W9YOFYNkO02jjHGT04Q="
    ];
  };

  nix.extraOptions = ''
    # Ensure we can still build when missing-server is not accessible
    fallback = true
  '';

  system.stateVersion = "24.05";
}
