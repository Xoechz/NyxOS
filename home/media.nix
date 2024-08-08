# Media and communication oriented apps and packages
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    discord
    spotify
    vlc
  ];
}
