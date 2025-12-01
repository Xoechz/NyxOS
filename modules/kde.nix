# configs regarding window management and kde, it is possible to swap this out if i want to change desktop environment
{ pkgs, ... }:
{
  # Enable the X11 windowing system. Disabling it seems to break a lot of stuff.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "at";
    variant = "";
  };

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
