# System wide themes
{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  fonts.packages = builtins.filter pkgs.lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
