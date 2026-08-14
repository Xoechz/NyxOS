{ inputs, ... }:
let
  # ---- Shared distributed-build definitions ----

  # Topology (acyclic): PC is a pure server (never offloads); the laptop is a
  # server that ALSO offloads to PC; other machines offload to PC (higher
  # speedFactor) or the laptop. PC uses the laptop as an ssh-ng *substitute*
  # only (fetch already-built paths), never offloading a build to it.
  #
  # Loop safety: builds only ever move DOWN the graph toward PC (the sink). No
  # machine is a client of a machine that is also a client of it, so a cross-arch
  # derivation can never bounce forever in `__build-remote`.

  # Builder machine specs (shared by the client + laptop/pc builder modules).
  pcMachine = {
    hostName = "EliasPC";
    systems = [ "x86_64-linux" "aarch64-linux" ];
    sshUser = "nixremote";
    maxJobs = 16;
    speedFactor = 4; # faster → preferred
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
    secretKeyFile = "/etc/nix/cache-priv-key.pem";
    publicKey = "EliasPC:FeMYLAaSK5o419ftDiAxhHs6x3n+tIsEq+LlZif0pg4=";
  };

  laptopMachine = {
    hostName = "EliasLaptop";
    systems = [ "x86_64-linux" "aarch64-linux" ];
    sshUser = "nixremote";
    maxJobs = 8;
    speedFactor = 1; # slower → fallback
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
    secretKeyFile = "/etc/nix/cache-priv-key.pem";
    publicKey = "EliasLaptop:9Cj03cpXtCehD9jP+WGIk5rxZKc8a4FO6S0Qr9uw9mg=";
  };

  # Keys every machine must trust for any path it may import: the caches plus
  # each builder's signing key.
  trustedKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    pcMachine.publicKey
    laptopMachine.publicKey
  ];

  # Public caches always used for substitution.
  cacheSubstituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
  ];

  # buildMachines + ssh-ng substituter entries for a given list of builders.
  asBuildMachines = builders: map (m: removeAttrs m [ "secretKeyFile" "publicKey" ]) builders;
  asSubstituters = builders: map (m: "ssh-ng://${m.sshUser}@${m.hostName}") builders;

  # Substitute preferentially from local builders first (reuse already-built
  # paths), then fall back to the public caches. Earlier entries win in Nix.
  preferredSubstituters = builders: asSubstituters builders ++ cacheSubstituters;
in
{
  flake-file.inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-compat.url = "github:nixos/flake-compat";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    nix-output-monitor = {
      url = "github:maralorn/nix-output-monitor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.git-hooks.follows = "git-hooks";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Sytem Module nix-utilities: install Nix dev tools and utilities for managing NixOS systems
  flake.modules.nixos.nix-utilities = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      nix-tree
      nix-output-monitor
      nvd
      statix
    ];
  };

  # System Module base-settings: enable flakes, allow unfree packages, configure the Nix daemon, and install Nix dev tools
  flake.modules.nixos.base-settings = { pkgs, lib, system, ... }: {

    nix = {
      settings = {
        fallback = true;

        # Parallelize: cores = build jobs within one derivation (kernel make -j),
        # max-jobs = concurrent derivations. "auto" = all CPUs.
        cores = 0; # 0 => use all cores
        max-jobs = "auto";

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

    boot.binfmt.emulatedSystems = lib.mkIf (system == "x86_64-linux") [ "aarch64-linux" ];

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs;[
        icu
      ];
    };

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

  # System Module distributed-build-client: offload this machine's builds to EliasPC (preferred) and EliasLaptop via SSH
  flake.modules.nixos.distributed-build-client = { ... }: {
    imports = [ inputs.self.modules.nixos.base-settings ];
    nix = {
      distributedBuilds = true;
      buildMachines = asBuildMachines [ pcMachine laptopMachine ];
      settings = {
        substituters = preferredSubstituters [ pcMachine laptopMachine ];
        trusted-public-keys = trustedKeys;
      };
    };
  };

  # System Module distributed-builder-laptop: offload the laptop's builds to EliasPC and serve others; sign local builds
  flake.modules.nixos.distributed-builder-laptop = { ... }: {
    imports = [ inputs.self.modules.nixos.base-settings ];
    nix = {
      distributedBuilds = true; # offloads to PC
      buildMachines = asBuildMachines [ pcMachine ];
      settings = {
        substituters = preferredSubstituters [ pcMachine ];
        trusted-public-keys = trustedKeys;
        secret-key-files = laptopMachine.secretKeyFile;
      };
    };
  };

  # System Module distributed-builder-pc: accept remote builds on EliasPC and reuse the laptop's store as a substitute
  flake.modules.nixos.distributed-builder-pc = { ... }: {
    imports = [ inputs.self.modules.nixos.base-settings ];
    nix.settings = {
      substituters = preferredSubstituters [ laptopMachine ];
      trusted-public-keys = trustedKeys;
      secret-key-files = pcMachine.secretKeyFile;
    };
  };

  # System Module nh: enable nh with weekly auto-cleanup, keeping the last 3 generations for 7 days
  flake.modules.nixos.nh = { lib, system, ... }: {
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

  # System Module home-manager: integrate Home Manager as a NixOS module with shared global packages
  flake.modules.nixos.home-manager = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ inputs.self.modules.homeManager.home-manager ];
    };
  };

  # Home Module home-manager: enable Home Manager self-management with monthly auto-expiry of old generations
  flake.modules.homeManager.home-manager = { ... }: {
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
