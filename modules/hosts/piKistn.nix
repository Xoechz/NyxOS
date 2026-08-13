# The system config base for PiKistn
{ inputs, ... }:
let system = "aarch64-linux"; in {
  flake.nixosConfigurations.PiKistn = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit system;
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      swapSize = 2; # GB
      users = [ "kistn" ];
    };
    modules = [
      inputs.self.modules.nixos.piKistn
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.piKistn = { lib, modulesPath, pkgs, ... }: {
    imports = with inputs.self.modules.nixos; [
      # bierkistn.nix
      bierkistn
      # desktop.nix
      language-en
      # network.nix
      ssh
      firewall-desktop
      # nix.nix
      distributed-build
      home-manager
      # system.nix
      pi4-system
      bluetooth
      sound
      swap
      # terminal.nix
      zsh
      # utilities.nix
      cli-utilities-minimal
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Modesetting for Wayland/Cage via the vc4-fkms-v3d driver
    hardware.raspberry-pi."4".fkms-3d.enable = true;

    # Raspberry Pi base audio (onboard 3.5mm jack).
    # Requires the nixos-hardware fix (targets &sound, not &audio) — see
    # system.nix which pins the srk/pi4audio fork for raspberry-pi-4.
    hardware.raspberry-pi."4".audio.enable = true;

    # Waveshare 7" 1024x600 HDMI display config
    hardware.raspberry-pi.configtxt.settings = {
      all = {
        hdmi_group = 2;
        hdmi_mode = 87;
        hdmi_cvt = "1024 600 60 6 0 0 0";
        dtoverlay = [
          "waveshare-ads7846,penirq=25,xmin=3900,xmax=200,ymin=200,ymax=3900,speed=50000,swapxy"
        ];
      };
    };

    # The waveshare-ads7846 overlay uses an ADS7846 resistive touch
    # controller over SPI.  The firmware module only ships RPi-vendor
    # overlays; provide this one inline so touch works without a
    # downloaded .dtbo file.
    hardware.deviceTree.overlays = [
      {
        name = "waveshare-ads7846";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "brcm,bcm2711";

            fragment@0 {
              target = <&gpio>;
              __overlay__ {
                ads7846_pins: ads7846_pins {
                  brcm,pins = <25 24 23 22>;
                  brcm,function = <0 1 1 1>; /* in out out out */
                };
              };
            };

            fragment@1 {
              target = <&spi0>;
              __overlay__ {
                status = "okay";
              };
            };

            fragment@2 {
              target = <&spi0>;
              __overlay__ {
                /* needed to avoid dtc warning */
                #address-cells = <1>;
                #size-cells = <0>;

                ads7846: ads7846@0 {
                  reg = <0>;
                  compatible = "ti,ads7846";
                  spi-max-frequency = <50000>;
                  interrupts = <25 2>; /* high-to-low edge */
                  interrupt-parent = <&gpio>;
                  pendown-gpio = <&gpio 25 0>;
                  ti,x-min = /bits/ 16 <200>;
                  ti,x-max = /bits/ 16 <3900>;
                  ti,y-min = /bits/ 16 <200>;
                  ti,y-max = /bits/ 16 <3900>;
                  ti,pressure-min = /bits/ 16 <0>;
                  ti,pressure-max = /bits/ 16 <255>;
                  ti,x-plate-ohms = /bits/ 16 <150>;
                  ti,debounce-max = /bits/ 16 <10>;
                  ti,debounce-tol = /bits/ 16 <3>;
                  ti,debounce-rep = /bits/ 16 <1>;
                  ti,settle-delay-usec = /bits/ 16 <100>;
                  ti,keep-vref-on;
                  swapxy = <1>;
                };
              };
            };
          };
        '';
      }
    ];

    services.cage = {
      enable = true;
      user = "kistn";
      program = "${inputs.bierkistn-radio.packages.${system}.bierkistnRadio}/bin/bierkistnRadio";
      environment = {
        QT_QPA_PLATFORM = "wayland";
        XDG_CACHE_HOME = "/home/kistn/.cache";
      };
    };

    users.users.kistn = {
      isNormalUser = true;
      description = "BierKistn Radio kiosk user";
      extraGroups = [ "networkmanager" "bluetooth" "audio" "video" "input" "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTZwgrSgkHT3WWJYIIe+dSvArtbp5JFetu6WpR5KC9t elias@EliasPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL71xmI34J5TlOzo6z0M3kTpzUTB7jxqiEvkALg4bcC6 root@EliasPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8x7bIB+Ai92GiQ/m6SzFdUODBW0chhmwC0OERjofTi elias@EliasLaptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDhjGdO4LZSBd21DrYSt1iJAC5f1kP1Q9yleTf9qZ7o root@EliasLaptop"
      ];
    };

    home-manager = {
      extraSpecialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        showBattery = false;
      };
      users.kistn = {
        imports = with inputs.self.modules.homeManager; [
          git
        ];

        home.stateVersion = "25.11";
      };
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "PiKistn";
      networkmanager.enable = true;
    };

    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.11";
  };
}
