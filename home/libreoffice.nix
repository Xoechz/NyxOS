{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_AT
  ];
}
