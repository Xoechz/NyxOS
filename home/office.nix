# Office work oriented apps and packages
{ pkgs, pkgs-stable, ... }:
{
  home.packages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_AT

    thunderbird

    teams-for-linux
  ] ++ [
    pkgs-stable.pdfarranger
  ];
}
