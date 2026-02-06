{ inputs, lib, system, pkgs, ... }:
{
  flake-file.inputs = {
    nix-output-monitor.url = "github:maralorn/nix-output-monitor";
    home-manager.url = "github:nix-community/home-manager";
  };

  # Module baseSettings: common nix and nixpkgs settings for all systems
  flake.modules.nixos.baseSettings = {
    environment.systemPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      nix-tree
      nix-output-monitor
      nvd
    ];

    nix = {
      settings = {
        fallback = true;

        # Enable flakes and new nix commands
        experimental-features = [ "nix-command" "flakes" ];

        # Trust nix daemon
        trusted-users = [ "elias" "nixremote" ];

        # Allow builders to use substitutes
        builders-use-substitutes = true;
      };

      # Optimize nix store usage
      optimise = {
        automatic = true;
        dates = "weekly";
      };
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;

    # Create nixremote user for remote builds
    users.users.nixremote = {
      isSystemUser = true;
      group = "nixremote";
      home = "/var/lib/nixremote";
      createHome = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTZwgrSgkHT3WWJYIIe+dSvArtbp5JFetu6WpR5KC9t elias@EliasPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL71xmI34J5TlOzo6z0M3kTpzUTB7jxqiEvkALg4bcC6 root@EliasPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8x7bIB+Ai92GiQ/m6SzFdUODBW0chhmwC0OERjofTi elias@EliasLaptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDhjGdO4LZSBd21DrYSt1iJAC5f1kP1Q9yleTf9qZ7o root@EliasLaptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEkkeMQneWIvzI9mzolIl2nyzt7pnzHqlNfk4zDlPyw elias@NixPi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF/LtEbMhHudYUlzGlYi3gdO819/U5KC1aJ5XNSkRJi root@NixPi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTsxwG/oZFKPLTH1SBVewZnWUaFJs9F+2o2SttnNv2j elias@FredPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWvZfUNVpUiiNM5ZWm7gExARtj/LXKADUGwnh/XuaNe root@FredPC"
      ];
    };

    users.groups.nixremote = { };

    # Allow nixremote to run nix commands without password
    security.sudo.extraRules = [
      {
        users = [ "nixremote" ];
        commands = [
          {
            command = "${pkgs.nix}/bin/nix-store";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.nix}/bin/nix-daemon";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # Module distributedBuild: settings for building on remote machines
  flake.modules.nixos.distributedBuild = {
    imports = [ inputs.self.modules.nixos.baseSettings ];
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "EliasPC";
          systems = [ "x86_64-linux" "aarch64-linux" ];
          sshUser = "nixremote";
          maxJobs = 16;
          speedFactor = 2;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          mandatoryFeatures = [ ];
        }
        # // TODO: Maybe someday add more build machines and substitutes (NAS, new Laptop, retired Laptop)
      ];

      settings = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "ssh-ng://nixremote@EliasPC"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "EliasPC:FeMYLAaSK5o419ftDiAxhHs6x3n+tIsEq+LlZif0pg4="
        ];
      };
    };
  };

  # Module distributedBuilder: settings for providing building capabilities to other machines
  flake.modules.nixos.distributedBuilder = {
    imports = [ inputs.self.modules.nixos.baseSettings ];
    nix = {
      distributedBuilds = false;
      settings = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # generate a new keypair with `nix keygen /etc/nix/cache-priv-key.pem`
        secret-key-files = "/etc/nix/cache-priv-key.pem";
      };
    };
  };

  # Module nh: enable and configure nh
  flake.modules.nixos.nh = {
    nixpkgs.overlays = lib.singleton
      (final: prev: {
        # Override nh to use the latest nix-output-monitor
        nh = prev.nh.override {
          nix-output-monitor = inputs.nix-output-monitor.packages.${system}.default;
        };
      });

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
        dates = "weekly";
      };
      flake = "/home/elias/NyxOS";
    };
  };

  # Module homeManager: enable home-manager service with basic settings
  flake.modules.home-manager.homeManager = {
    services.home-manager = {
      autoExpire = {
        enable = true;
        frequency = "monthly";
        timestamp = "-30 days";
      };
    };

    programs.home-manager.enable = true;
  };
}
