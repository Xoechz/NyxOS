{ ... }:
{
  # System Module tv: dvb-s setup for tv
  flake.modules.nixos.tv = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      w_scan2
      dvb-apps
    ];

    # // TODO: expand with https://linuxtv.org/
  };
}
