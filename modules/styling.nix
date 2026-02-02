# System wide themes
{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  fonts = {
    packages = with pkgs;[
      # JetBrains officially created font for developers
      nerd-fonts.jetbrains-mono
      # `0` and `O` very similar, characters are either very curvy or straight lined
      nerd-fonts.noto
    ];

    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
