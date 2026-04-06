{ ... }: {
  # System Module grub: configure GRUB EFI bootloader with a UEFI firmware entry
  flake.modules.nixos.grub = { lib, ... }: {
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = lib.mkDefault "nodev";
      useOSProber = lib.mkDefault false;
      extraEntries = lib.mkDefault ''
        menuentry "UEFI Firmware Settings" --class efi {
          fwsetup
        }
      '';
    };
  };

  # System Module basic-system: set timezone to Vienna, enable all firmware, fwupd, fstrim, and NTFS support
  flake.modules.nixos.basic-system = { ... }: {
    time.timeZone = "Europe/Vienna";

    hardware.enableAllFirmware = true;
    hardware.enableAllHardware = true;

    services.fwupd.enable = true;
    services.fstrim.enable = true;
    services.envfs.enable = true;

    boot.supportedFilesystems = [
      "ntfs"
    ];
  };

  # System Module swap: configure zram swap and an encrypted swapfile sized via the swapSize specialArg (in GB)
  flake.modules.nixos.swap = { swapSize, ... }: {
    zramSwap.enable = true;
    swapDevices = [{
      device = "/var/lib/swapfile";
      size = swapSize * 1024; # GB
      randomEncryption.enable = true;
    }];
  };

  # System Module bluetooth: enable Bluetooth, power on at boot, and enable experimental features for battery reporting
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

  # System Module printing: enable CUPS with the HP HPLIP driver and SANE scanning support
  flake.modules.nixos.printing = { pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ hplipWithPlugin ];
    };

    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };

    environment.systemPackages = with pkgs; [
      hplipWithPlugin
    ];
  };

  # System Module sound: enable PipeWire with ALSA and PulseAudio compatibility, rtkit, and media control tools
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

  # System Module cpu-intel: enable Intel CPU microcode updates and install PowerTOP
  flake.modules.nixos.cpu-intel = { pkgs, ... }: {
    hardware.cpu.intel.updateMicrocode = true;

    environment.systemPackages = with pkgs; [
      powertop
    ];
  };

  # System Module cpu-amd: enable AMD CPU microcode updates
  flake.modules.nixos.cpu-amd = { ... }: {
    hardware.cpu.amd.updateMicrocode = true;
  };

  # System Module gpu-nvidia: enable NVIDIA proprietary drivers with modesetting and 32-bit graphics support
  flake.modules.nixos.gpu-nvidia = { pkgs, ... }: {
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

  # System Module gpu-amd: enable AMDGPU driver with ROCm/OpenCL support, GPU frequency boosting, and 32-bit graphics
  flake.modules.nixos.gpu-amd = { pkgs, ... }: {
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
