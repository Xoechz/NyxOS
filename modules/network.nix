{ ... }: {
  # System Module ssh: enable and configure ssh server and client
  flake.modules.nixos.ssh = { ... }: {
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
      openFirewall = true;
    };

    # SSH known hosts for distributed builds
    programs.ssh.knownHosts = {
      EliasPC = {
        hostNames = [ "EliasPC" "EliasPC.local" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBHAqDy+XbGANEjlFRgFu/KhiA1Y08RSekbArf/o/9H";
      };
      EliasLaptop = {
        hostNames = [ "EliasLaptop" "EliasLaptop.local" ];
        publicKey = "eliaslaptop ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQVC/JIg4qiVV18O5p+nABWSrM6O4JRQPxY7XBUtQ+L";
      };
      FredPC = {
        hostNames = [ "FredPC" "FredPC.local" ];
        publicKey = "fredpc ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINO21u53GTTwxbOX+mmhuGVBHFX5kAOAgyeI06/NCblr";
      };
      NixPi = {
        hostNames = [ "NixPi" "NixPi.local" ];
        publicKey = "nixpi ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyuYVNGKSrpwWacyBFdqPdFxRTNhu8bcmQ0sk8j786T";
      };
    };
  };

  # System Module firewallDesktop: enable and configure firewall with basic settings
  flake.modules.nixos.firewallDesktop = { ... }: {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        # SSH
        22
        # HTTP
        80
        # HTTPS
        443
        # Spotify
        57621
        # Steam Local Network Game Transfer and Remote Play
        27015
        27036
        27040
      ];
      allowedUDPPorts = [
        # Spotify
        5353
        # Stardew Valley LAN Multiplayer
        24642
        #Steam
        27015
      ];
      allowedTCPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
        # Steam Local Network Game Transfer and Remote Play
        { from = 27031; to = 27036; }
      ];
      trustedInterfaces = [ "docker0" ];
    };
  };

  # System Module firewallServer: enable and configure firewall with server settings
  flake.modules.nixos.firewallServer = { ... }: {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        # SSH
        22
        # HTTP
        80
        # HTTPS
        443
        # DNS
        53
      ];
      allowedUDPPorts = [
        # DNS
        53
      ];
    };
  };

  # System Module vpn: enable and configure mullvad and wireguard vpn
  flake.modules.nixos.vpn = { pkgs, ... }: {
    # needed for wireguard and mullvad to work properly
    services.resolved.enable = true;

    services.mullvad-vpn.enable = true;

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };

  # System Module blocky: enable and configure blocky adblocker
  flake.modules.nixos.blocky = { ... }: {
    services.blocky = {
      enable = true;
      settings = {
        ports.dns = 53; # Port for incoming DNS Queries.
        upstreams.groups.default = [
          "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
        ];
        # For initially solving DoH/DoT Requests when no system Resolver is available.
        bootstrapDns = {
          upstream = "https://one.one.one.one/dns-query";
          ips = [ "1.1.1.1" "1.0.0.1" ];
        };
        #Enable Blocking of certain domains.
        blocking = {
          denylists = {
            #Adblocking
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
              "https://blocklistproject.github.io/Lists/ads.txt"
              "https://blocklistproject.github.io/Lists/malware.txt"
              "https://blocklistproject.github.io/Lists/scam.txt"
            ];
          };
          # allowlist = {
          #   ads = [
          #     # add domains that should not be blocked here
          #   ];
          # };
          #Configure what block categories are used
          clientGroupsBlock = {
            default = [ "ads" ];
          };
        };
        customDNS = {
          customTTL = "1h";
          mapping = {
            "gateway.lan" = "192.168.0.1";
            "nixpi.lan" = "192.168.0.10";
            "printer.lan" = "192.168.0.11";
            "eliasPc.lan" = "192.168.0.12";
            "eliasLaptop.lan" = "192.168.0.13";
            "fredPc.lan" = "192.168.0.14";
          };
        };
        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
        };
      };
    };
  };

  # Home Module sailing: enable and configure sailing applications ;)
  flake.modules.homeManager.sailing = { pkgs, ... }: {
    home.packages = with pkgs; [
      tor-browser
      transmission_4-qt
    ];
  };
}
