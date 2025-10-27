{ ... }:
{
  imports =
    [
      ./default.nix
      ./editors.nix
      ./office.nix
      ./defaultApplications.nix
      ./terminal.nix
    ];

  home.username = "gerhard";
  home.homeDirectory = "/home/gerhard";
}
