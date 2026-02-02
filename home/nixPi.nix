{ ... }:

{
  imports =
    [
      ./default.nix
      ./terminal.nix
    ];

  home.username = "elias";
  home.homeDirectory = "/home/elias";
}
