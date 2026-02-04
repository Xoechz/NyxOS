{ inputs, lib, system, pkgs, ... }:
{
  flake-file.inputs = {
    nix-output-monitor.url = "github:maralorn/nix-output-monitor";
    home-manager.url = "github:nix-community/home-manager";
  };

  flake.modules = {
    nixos = {
      # Module nh: enable and configure nh
      nh = {
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

      # Module baseSettings: common nix and nixpkgs settings for all systems
      baseSettings = {
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
      };

      # Module distributedBuild: settings for building on remote machines
      distributedBuild = {
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
      distributedBuilder = {
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
    };

    home-manager = {
      # Module homeManager: enable home-manager service with basic settings
      homeManager = {
        services.home-manager = {
          autoExpire = {
            enable = true;
            frequency = "monthly";
            timestamp = "-30 days";
          };
        };

        programs.home-manager.enable = true;
      };
    };
  };
}
