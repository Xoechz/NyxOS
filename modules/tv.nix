{ ... }:
{
  # System Module tv: dvb-s setup for tv
  flake.modules.nixos.tv = { pkgs, ... }: {
    nixpkgs.overlays = [
      (self: super: {
        tvheadend = self.callPackage ../packages/tvheadend/tvheadend.nix { };
      })
      (self: super: {
        oscam = self.callPackage ../packages/oscam/oscam.nix { };
      })
    ];

    environment.systemPackages = with pkgs; [
      w_scan2
      dvb-apps
      usbutils
      tvheadend
      oscam
    ];

    # register oscam and tvheadend as servies for systemd
    systemd.services.tvheadend = {
      description = "TVHeadend DVB streaming server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tvheadend}/bin/tvheadend -u hts -g video -C -6 --http_port 9981 --htsp_port 9982";
        Restart = "always";
        User = "hts";
        Group = "video";
      };
    };

    systemd.services.oscam = {
      description = "OSCam Card Sharing Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.oscam}/bin/oscam";
        Restart = "always";
      };
    };

    users.users.hts = {
      group = "video";
      isSystemUser = true;
    };

    networking.firewall.allowedTCPPorts = [ 9981 9982 8888 ];
  };
}
