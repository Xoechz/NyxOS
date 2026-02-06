{ ... }: {
  # System Module grub: configure grub bootloader
  flake.modules.nixos.grub = { lib, ... }: {
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.grub =
      {
        enable = true;
        efiSupport = true;
        device = lib.mkDefault "nodev";
        useOSProber = lib.mkDefault false;
        memtest86.enable = true;
        extraEntries = lib.mkDefault ''
          menuentry "UEFI Firmware Settings" --class efi {
            fwsetup
          }
        '';
      };
  };

  # System Module basicSystem: configure firmware updates, file system tools, and other basic utilities
  flake.modules.nixos.basicSystem = { ... }: {
    time.timeZone = "Europe/Vienna";

    services.fwupd.enable = true;
    services.fstrim.enable = true;

    boot.supportedFilesystems = [
      "ntfs"
    ];
  };

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

  # System Module swap32: configure 32 GB swap
  flake.modules.nixos.swap32 = { ... }: {
    zramSwap.enable = true;
    swapDevices = [{
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32 GB
      randomEncryption.enable = true;
    }];
  };

  # System Module swap18: configure 18 GB swap
  flake.modules.nixos.swap18 = { ... }: {
    zramSwap.enable = true;
    swapDevices = [{
      device = "/var/lib/swapfile";
      size = 18 * 1024; # 18 GB
      randomEncryption.enable = true;
    }];
  };

  # System Module swap8: configure 8 GB swap
  flake.modules.nixos.swap8 = { ... }: {
    zramSwap.enable = true;
    swapDevices = [{
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 8 GB
      randomEncryption.enable = true;
    }];
  };

  # System Module bluetooth: configure bluetooth settings
  flake.modules.nixos.bluetooth = { ... }: {
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
  };

  # System Module printing: configure printing services for the HP printer at home
  flake.modules.nixos.printing = { pkgs, ... }: {
    services.printing =
      {
        enable = true;
        drivers = with pkgs; [ hplip ];
      };

    environment.systemPackages = with pkgs; [
      hplip
    ];
  };

  # System Module sound: configure sound settings
  flake.modules.nixos.sound = { pkgs, lib, config, ... }: {
    security.rtkit.enable = true;

    services = {
      dbus.packages = [ pkgs.gcr ];

      geoclue2.enable = true;

      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    environment.variables = {
      # Combine required library search paths; force to avoid conflicts with other modules
      LD_LIBRARY_PATH = lib.mkForce (builtins.concatStringsSep ":" [
        "/run/current-system/sw/lib" # base system libs
        "${config.services.pipewire.package.jack}/lib" # pipewire jack (was defined elsewhere causing conflict)
      ]);
    };
  };

  # System Module cpuIntel: configure Intel CPU microcode updates
  flake.modules.nixos.cpuIntel = { pkgs, ... }: {
    hardware.cpu.intel.updateMicrocode = true;

    environment.systemPackages = with pkgs; [
      powertop
    ];
  };

  # System Module gpuNvidia: configure Nvidia GPU settings
  flake.modules.nixos.gpuNvidia = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      btop-cuda
      nvtopPackages.nvidia
    ];

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = false;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };

  # System Module gpuAmd: configure AMD GPU settings
  flake.modules.nixos.gpuAmd = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      btop-rocm
    ];

    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];
    boot.kernelModules = [ "amdgpu" ];

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];

    hardware = {
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    # Enable GPU frequency boosting
    boot.extraModprobeConfig = ''
      options amdgpu gpu_sched_hw_submission=2
      options amdgpu ppfeature_mask=0xffffffff
    '';
  };
}
