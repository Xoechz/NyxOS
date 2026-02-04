{ pkgs, ... }: {
  flake.modules = {
    nixos = {
      # Module diagnostics: add useful diagnostics tools
      diagnostics = {
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

          baobab
          bruno
        ];
      };

      # Module basics: basic packages needed for a functional system
      basics = {
        environment.systemPackages = with pkgs; [
          wget
          curl

          git
          zip
          xz
          unzip

          gparted
          openssl

          iptables
          inetutils

          gnome-multi-writer
          efibootmgr
        ];


      };

      # Module autoUpdate: automatic system updates
      autoUpdate = {
        services.cron = {
          enable = true;
          systemCronJobs = [
            "0 */2 * * *      root    cd /home/elias/NyxOS && ./update.sh >> /var/log/nixos-update.log 2>&1"
          ];
        };
      };
    };

    home-manager = {
      # Module git: configure git for home manager
      git = {
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
    };
  };
}
