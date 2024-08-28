# The system wide themes that will be applied by stylix
{ pkgs, ... }:
{
  stylix.enable = true;
  stylix.image = ../nixos-wallpaper-catppuccin-mocha.png;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  stylix.cursor = {
    size = 24;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
  };

  stylix.targets.grub.enable = true;
  stylix.targets.grub.useImage = true;
  stylix.targets.nixos-icons.enable = true;

  stylix.fonts.sizes = {
    applications = 10;
    terminal = 10;
    desktop = 10;
    popups = 10;
  };
}
