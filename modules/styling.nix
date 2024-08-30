# System wide themes
{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  fonts.packages = with pkgs;[ nerdfonts ];
}
