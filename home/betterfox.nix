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
        enableAllSections = true;
      };
    };
  };
}
