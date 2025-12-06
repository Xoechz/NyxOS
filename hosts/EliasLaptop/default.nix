# The system config base for EliasLaptop
{ ... }:

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
      extraEntries = ''
        menuentry "Windows" --class windows --class os {
          insmod ntfs
          search --no-floppy --set=root --fs-uuid C236-4D6C
          chainloader /efi/Microsoft/Boot/bootmgfw.efi
        };
        menuentry "UEFI Firmware Settings" --class efi {
          fwsetup
        }
      '';
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

  hardware.nvidia.prime = {
    reverseSync.enable = true;
    # Enable if using an external GPU
    allowExternalGpu = false;

    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };

  # power management
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true;
  services.tlp =
    {
      enable = true;
      settings = {
        # CPU governors and energy/perf policy
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Performance caps to reduce heat/noise on AC, save battery on BAT
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 90;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;

        CPU_BOOST_ON_AC = "1";
        CPU_BOOST_ON_BAT = "0";

        # PCIe and runtime power management
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        RUNTIME_PM_DRIVER_BLACKLIST = "nouveau amdgpu nvidia";
        RUNTIME_PM_DEVICE_BLACKLIST = "";

        # USB autosuspend
        USB_AUTOSUSPEND = 0;

        # SATA link power management
        SATA_LINKPWR_ON_AC = "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT = "min_power";

        # WiFi power saving
        WIFI_PWR_ON_AC = 1;
        WIFI_PWR_ON_BAT = 5;

        # Audio power saving
        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;

        # Bluetooth power saving
        BT_POWER = 1;

        # Battery charge thresholds
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;

        # Optional platform profiles (if supported)
        PLATFORM_PROFILE_ON_AC = "balanced-performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };

  services.github-runners.default = {
    enable = true;
    tokenFile = "/run/secrets/github-runner/default.token";
    url = "https://github.com/swk5-2025ws/delifhery-bb-g1-leonhardsberger";
  };

  system.stateVersion = "24.05";
}
