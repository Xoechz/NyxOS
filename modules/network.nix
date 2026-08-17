{ ... }: {
  # System Module ssh: enable OpenSSH server (key-only auth) and configure client host aliases and known hosts
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
    programs.ssh = {
      knownHosts = {
        EliasPC = {
          hostNames = [ "EliasPC" "EliasPC.bruckner-domain.net" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBHAqDy+XbGANEjlFRgFu/KhiA1Y08RSekbArf/o/9H";
        };
        EliasLaptop = {
          hostNames = [ "EliasLaptop" "EliasLaptop.bruckner-domain.net" ];
          publicKey = "eliaslaptop ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQVC/JIg4qiVV18O5p+nABWSrM6O4JRQPxY7XBUtQ+L";
        };
      };
      extraConfig = "
        Host EliasPC
          HostName EliasPC.bruckner-domain.net
          User elias
        Host EliasLaptop
          HostName EliasLaptop.bruckner-domain.net
          User elias
        Host FredPC
          HostName FredPC.bruckner-domain.net
          User elias
        Host NixPi
          HostName NixPi.bruckner-domain.net
          User elias
        Host PiKistn
          HostName PiKistn.bruckner-domain.net
          User kistn
      ";
    };
  };

  # System Module firewall-desktop: enable firewall with ports for SSH, Steam, Spotify, KDE Connect, and Stardew Valley LAN
  flake.modules.nixos.firewall-desktop = { ... }: {
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
        57622
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

  # System Module firewall-server: enable firewall with minimal ports for SSH, HTTP/HTTPS, and DNS only
  flake.modules.nixos.firewall-server = { ... }: {
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

  # System Module vpn: enable Mullvad VPN service and install WireGuard tools
  flake.modules.nixos.vpn = { pkgs, ... }: {
    # needed for wireguard and mullvad to work properly
    services.resolved.enable = true;

    services.mullvad-vpn.enable = true;

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };

  # System Module blocky: run Blocky as a local DNS resolver with ad/malware blocking and custom LAN hostname mappings
  flake.modules.nixos.blocky = { ... }: {
    services.blocky = {
      enable = true;
      settings = {
        certFile = "/etc/ssl/crt.pem";
        keyFile = "/etc/ssl/key.pem";
        ports.dns = 53; # Port for incoming DNS Queries.
        ports.https = 443; # Port for incoming DoH Queries.
        ports.tls = 853; # Port for incoming DoT Queries.
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
            "gateway.bruckner-domain.net" = "192.168.0.1";
            "nixpi.bruckner-domain.net" = "192.168.0.10";
            "printer.bruckner-domain.net" = "192.168.0.11";
            "eliasPc.bruckner-domain.net" = "192.168.0.12";
            "eliasLaptop.bruckner-domain.net" = "192.168.0.13";
            "fredPc.bruckner-domain.net" = "192.168.0.14";
            "piKistn.bruckner-domain.net" = "192.168.0.15";
          };
        };
        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
        };
      };
    };

    # Point system DNS to blocky
    networking.nameservers = [ "127.0.0.1" ];
    networking.dhcpcd.extraConfig = "nohook resolv.conf";
  };

  # System Module cloudflared: run a Cloudflare Tunnel daemon for zero-trust remote access to local services
  flake.modules.nixos.cloudflared = { pkgs, ... }: {
    services.cloudflared = {
      enable = true;
      tunnels."0e30ac2d-5c3e-4b6a-9c8c-2194ac5f60c2" = {
        credentialsFile = "/etc/cloudflared/0e30ac2d-5c3e-4b6a-9c8c-2194ac5f60c2.json";
        certificateFile = "/etc/cloudflared/cert.pem";
        default = "http_status:404";
      };
    };

    environment.systemPackages = with pkgs; [
      cloudflared
    ];

    services.openssh.settings.Macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-256"
    ];
  };

  # System Module warp: enable Cloudflare WARP client for secure DNS and network privacy
  flake.modules.nixos.warp = { ... }: {
    services.cloudflare-warp.enable = true;
  };

  # Home Module sailing: install sailing applications ;)
  flake.modules.homeManager.sailing = { pkgs, ... }: {
    home.packages = with pkgs; [
      tor-browser
      transmission_4-qt
    ];
  };
}
