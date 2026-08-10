{ inputs, ... }: {
  flake-file.inputs = {
    bierkistn-radio = {
      url = "git+file:///home/elias/Repos/BierKistnRadio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System Module bierkistn: install the BierKistn Radio UI, spotifyd as a user service, and grant the kiosk user the D-Bus actions it needs
  flake.modules.nixos.bierkistn = { pkgs, lib, config, ... }: {
    environment.systemPackages = with pkgs; [
      spotifyd
    ];

    environment.etc."spotifyd.conf".text = ''
      [global]
      use_mpris = true
      device_name = "BierKistn"
      bitrate = 320
    '';

    systemd.user.services.spotifyd = {
      enable = true;
      description = "spotifyd — Spotify playing daemon";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path /etc/spotifyd.conf --cache-path %h/.cache/spotifyd";
        Restart = "always";
        RestartSec = 12;
      };
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "kistn" && (
          action.id.indexOf("org.freedesktop.NetworkManager.") === 0 ||
          action.id.indexOf("org.freedesktop.login1.") === 0
        )) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
