{ inputs, ... }: {
  flake-file.inputs = {
    systems.url = "github:nix-systems/default";
    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.import-tree.follows = "import-tree";
      inputs.systems.follows = "systems";
    };
  };

  # System Module firefox: enable Firefox system-wide
  flake.modules.nixos.firefox = { config, ... }: {
    programs.firefox = {
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      enable = true;
    };
  };

  # System Module chromium: install Chromium with Widevine DRM
  flake.modules.nixos.chromium = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      (chromium.override {
        enableWideVine = true;
      })
    ];
  };

  # Home Module betterfox: configure Firefox with Betterfox hardened user.js and set it as the default browser
  flake.modules.homeManager.betterfox = { lib, config, ... }: {
    imports = [ inputs.betterfox-nix.modules.homeManager.betterfox ];

    # In firefox
    programs.firefox = {
      configPath = "${config.xdg.configHome}/mozilla/firefox";
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
