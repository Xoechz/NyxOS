{ inputs, pkgs, ... }: {
  flake-file.inputs = {
    betterfox-nix.url = "github:HeitorAugustoLN/betterfox-nix";
  };

  flake.modules = {
    nixos = {
      # Module firefox: configure basic firefox
      firefox = {
        programs.firefox = {
          enable = true;
        };
      };
      # Module chromium-no-gpu: chromium with disabled gpu acceleration
      chromium-no-gpu = {
        nvironment.systemPackages = with pkgs; [
          (chromium.override {
            commandLineArgs = [ "--disable-gpu" ];
          })
        ];
      };
    };

    home-manager = {
      # Module betterfox: configure betterfox instead of firefox in home manager
      betterfox = {
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
      };
    };
  };
}
