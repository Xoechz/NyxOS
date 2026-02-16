{ ... }:
{
  # System Module tv: dvb-s setup for tv
  flake.modules.nixos.tv = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      w_scan2
      dvb-apps
      tvheadend
      oscam
    ];

    # // TODO: expand with https://linuxtv.org/
    nixpkgs.overlays.tvheadend = self: super: {
      tvheadend = self.callPackage ../packages/tvheadend/tvheadend.nix { };
      oscam = self.callPackage ../packages/oscam/oscam.nix { };
    };
  };
}
