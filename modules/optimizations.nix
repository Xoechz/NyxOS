{ ... }: {
  # System Module optimizationsPC: configure optimizations for PC hardware
  flake.modules.nixos.optimizationsPC = { pkgs, lib, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

    services.system76-scheduler = {
      enable = true;
      settings.cfsProfiles.enable = true;
    };

    services.thermald.enable = true;
    services.power-profiles-daemon.enable = false;
    powerManagement.powertop.enable = false;

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
  };

  # System Module optimizationsLaptop: configure optimizations for laptop hardware
  flake.modules.nixos.optimizationsLaptop = { pkgs, lib, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

    services.system76-scheduler = {
      enable = true;
      settings.cfsProfiles.enable = true;
    };

    services.auto-cpufreq.enable = false;
    services.power-profiles-daemon.enable = false;
    powerManagement.powertop.enable = false;

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
  };
}
