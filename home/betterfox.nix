{ betterfox-nix, ... }:
{
  imports = [ betterfox-nix.modules.homeManager.betterfox ];

  # In firefox
  programs.firefox = {
    enable = true;
    profiles.elias.extensions.force = true;

    betterfox = {
      enable = true;

      profiles.elias = {
        # Set this to enable all sections by default
        enableAllSections = true;

        settings = {
          # To enable/disable specific sections
          fastfox.enable = true;

          # To enable/disable specific subsections
          peskyfox = {
            enable = true;
          };

          # To enable/disable specific options
          securefox = {
            enable = true;
          };
        };
      };
    };
  };
}
