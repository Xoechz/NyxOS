# The system config base for EliasPC
{ pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/kde.nix
      ../../modules/overlays.nix
      ../../modules/steam.nix
      ../../modules/amd.nix
      ../../modules/dev.nix
      ../../modules/styling.nix
      ../../modules/language_en_at.nix
    ];

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub =
    {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;
      memtest86.enable = true;
      extraEntries = ''
        menuentry "UEFI Firmware Settings" --class efi {
          fwsetup
        }
      '';
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

  environment.systemPackages = with pkgs; [
    btop-rocm
  ];

  hardware.cpu.intel.updateMicrocode = true;

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  # Power management optimized for high performance
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # Aggressive CPU scaling for maximum performance
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_BOOST_ON_AC = "1";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;

      # Disable runtime PM on AC to prevent USB devices from suspending
      RUNTIME_PM_ON_AC = "off";

      # Disable USB autosuspend to prevent input devices from suspending
      USB_AUTOSUSPEND = 0;
      USB_AUTOSUSPEND_ON_AC = 0;

      # Optimize disk performance (use noop for SSDs)
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      DISK_IDLE_SECS_ON_AC = 0;

      # Disable audio powersave for better responsiveness
      SOUND_POWER_SAVE_ON_AC = 0;

      # Optimize PCIe for performance
      PCIE_ASPM_ON_AC = "off";
    };
  };

  # Kernel parameters for high performance
  boot.kernelParams = [
    # Disable CPU power states for consistent performance
    "intel_pstate=disable"
  ];

  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # enable flakes and new nix commands
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "elias" "nixremote" ];
      secret-key-files = "/etc/nix/cache-priv-key.pem";
    };
  };

  system.stateVersion = "24.05";
}
