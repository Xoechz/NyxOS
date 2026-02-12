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

    hardware.enableRedistributableFirmware = true;

    services.fwupd.enable = true;
    services.fstrim.enable = true;
    security.polkit.enable = true;
    services.dbus.enable = true;

    boot.supportedFilesystems = [
      "ntfs"
    ];
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
  flake.modules.nixos.sound = { pkgs, ... }: {
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
        wireplumber.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      playerctl
      pavucontrol
    ];
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
