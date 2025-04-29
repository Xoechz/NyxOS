# configs regarding window management and kde, it is possible to swap this out if i want to change desktop environment
{ pkgs, ... }:
{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "at";
    variant = "";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # set KDE to wayland
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;

  # exclude some packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    khelpcenter
    konsole
    elisa
  ];
}
