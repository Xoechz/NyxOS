# Office work oriented apps and packages
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_AT

    thunderbird

    pdfarranger
  ];
}
