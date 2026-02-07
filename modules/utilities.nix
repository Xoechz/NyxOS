{ ... }: {
  # System Module cliUtilities: add useful tools
  flake.modules.nixos.cliUtilities = { pkgs, ... }: {
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

  # Home Module git: configure git for home manager
  flake.modules.homeManager.git = { ... }: {
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

  # Home Module guiUtilities: Useful gui utilities
  flake.modules.homeManager.guiUtilities = { pkgs, ... }: {
    home.packages = with pkgs; [
      baobab
      bruno
      gparted
      gnome-multi-writer
    ];
  };
}
