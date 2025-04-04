# user wide themes
{ catppuccin, ... }:
{
  imports =
    [
      catppuccin.homeModules.catppuccin
    ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
    vscode.enable = false; # vscode setup is done non declaratively. Sorry!
  };
}
