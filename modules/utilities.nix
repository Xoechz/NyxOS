{ ... }: {
  # System Module cliUtilities: install network, filesystem, hardware, and diagnostic CLI tools (fastfetch, jq, curl, etc.)
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

      wakeonlan
      # gparted has a gui but needs to be run as root, so we add it here to avoid confusion in the gui utilities section
      gparted
    ];
  };

  # Home Module git: configure Git with user identity, LFS, rebase-on-pull, and a log graph alias
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

  # Home Module guiUtilities: install Baobab disk analyser, Bruno API client, and GNOME multi-writer
  flake.modules.homeManager.guiUtilities = { pkgs, ... }: {
    home.packages = with pkgs; [
      baobab
      bruno
      gnome-multi-writer
    ];
  };
}
