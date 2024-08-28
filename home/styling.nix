# user wide themes
{ catppuccin, ... }:
{
  imports =
    [
      catppuccin.homeManagerModules.catppuccin
    ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";

    pointerCursor = {
      enable = true;
      flavor = "mocha";
      accent = "dark";
    };
  };
}
