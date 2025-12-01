# configs regarding window management and kde, it is possible to swap this out if i want to change desktop environment
{ pkgs, ... }:
{
  # I am only using wayland, so no need for xserver
  services.xserver.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  # set KDE to wayland
  services.displayManager = {
    defaultSession = "plasma";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # exclude some packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    khelpcenter
    konsole
    elisa
  ];
}
