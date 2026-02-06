{ pkgs, ... }: {
  # Module cliUtilities: add useful  tools
  flake.modules.nixos.cliUtilities = {
    environment.systemPackages = with pkgs; [
      fastfetch
      mtr
      iperf3
      dnsutils

      which
      tree
      iotop
      iftop

      strace
      ltrace
      lsof
      traceroute

      ethtool
      pciutils
      usbutils

      hdparm

      ntfs3g
      exfat

      dmidecode

      lm_sensors
      sysstat

      clinfo

      wayland-utils

      parallel
      libwebp

      jq
      nodejs
    ];
  };

  # Module basics: basic packages needed for a functional system
  flake.modules.nixos.basics = {
    environment.systemPackages = with pkgs; [
      wget
      curl

      git
      zip
      xz
      unzip

      openssl

      iptables
      inetutils

      efibootmgr
    ];


  };

  # Module autoUpdate: automatic system updates
  flake.modules.nixos.autoUpdate = {
    services.cron = {
      enable = true;
      systemCronJobs = [
        "0 */2 * * *      root    cd /home/elias/NyxOS && ./update.sh >> /var/log/nixos-update.log 2>&1"
      ];
    };
  };

  # Module git: configure git for home manager
  flake.modules.home-manager.git = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Elias Leonhardsberger";
          email = "elias.leonhardsberger@gmail.com";
        };
        alias = {
          graph = "log --decorate --oneline --graph --max-count=20";
        };
        pull.rebase = true;
        core.autocrlf = "input";
      };
      lfs.enable = true;
    };
  };

  # Module guiUtilities: Usefull gui utilities
  flake.modules.home-manager.guiUtilities = {
    home.packages = with pkgs; [
      baobab
      bruno
      gparted
      gnome-multi-writer
    ];
  };
}
