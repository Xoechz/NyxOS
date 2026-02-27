{ inputs, ... }: {
  flake-file.inputs = {
    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.import-tree.follows = "import-tree";
      inputs.systems.follows = "systems";
    };
  };

  # System Module firefox: configure basic firefox
  flake.modules.nixos.firefox = { ... }: {
    programs.firefox = {
      enable = true;
    };
  };

  # System Module chromium-no-gpu: chromium with disabled gpu acceleration
  flake.modules.nixos.chromium-no-gpu = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
      (chromium.override {
        enableWideVine = true;
        commandLineArgs = [ "--disable-gpu" ];
      })
    ];
  };

  # Home Module betterfox: configure betterfox instead of firefox in home manager
  flake.modules.homeManager.betterfox = { lib, ... }: {
    imports = [ inputs.betterfox-nix.modules.homeManager.betterfox ];

    # In firefox
    programs.firefox = {
      enable = true;
      profiles.elias.extensions.force = true;

      betterfox = {
        enable = true;

        profiles.elias = {
          enableAllSections = true;
        };
      };
    };

    xdg.mimeApps = {
      enable = lib.mkDefault true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
      };
    };
  };
}
