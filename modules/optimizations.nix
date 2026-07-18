{ ... }: {
  # System Module optimizations-pc: use the latest kernel with minimal background services and desktop-appropriate sysctl tuning
  flake.modules.nixos.optimizations-pc = { pkgs, lib, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

    services.thermald.enable = true;
    services.power-profiles-daemon.enable = false;
    powerManagement.powertop.enable = false;

    boot.kernelParams = [ "nowatchdog" "amdgpu.gpu_recovery=1" ];

    boot.kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 5;
      "vm.dirty_background_ratio" = 2;
    };

    # Remove network-online.target from boot dependency graph — prevents boot stall without disabling the service
    systemd.targets.network-online.wantedBy = lib.mkForce [ ];
    systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
  };

  # System Module optimizations-laptop: use the latest kernel with TLP for AC/battery power profiles and an 80% charge threshold
  flake.modules.nixos.optimizations-laptop = { pkgs, lib, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

    services.auto-cpufreq.enable = false;
    services.power-profiles-daemon.enable = false;
    powerManagement.powertop.enable = false;

    services.thermald.enable = true;
    services.tlp = {
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
        CPU_MAX_PERF_ON_BAT = 75;

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

    boot.kernelParams = [ "nowatchdog" ];

    boot.kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 5;
      "vm.dirty_background_ratio" = 2;
    };

    # Remove network-online.target from boot dependency graph — prevents boot stall without disabling the service
    systemd.targets.network-online.wantedBy = lib.mkForce [ ];
    systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
  };
}
