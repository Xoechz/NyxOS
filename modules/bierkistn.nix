{ inputs, ... }: {
  flake-file.inputs = {
    bierkistn-radio = {
      url = "github:Xoechz/BierKistnRadio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System Module bierkistn: install the BierKistn Radio UI, configure exclusive Spotify/Bluetooth source services and app-mediated pairing, grant the kiosk user required D-Bus actions, and pull in the bierkistn Home Module for all users
  flake.modules.nixos.bierkistn = { pkgs, config, ... }: {
    environment.systemPackages = with pkgs; [
      spotifyd
      ddcutil
    ];

    # Bluetooth is only brought up by the app after spotifyd has stopped.
    # powerOnBoot and AutoEnable=false prevent radio startup/reconnection
    # before the app has selected Bluetooth and registered its pairing agent.

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings.General = {
        AutoEnable = false;
      };
    };

    # A2DP-sink-only role. The speaker is a sink that phones drive; it never
    # sources audio. bluez5.auto-connect=[] means no device auto-connects.
    # dummy-avrcp-player registers an AVRCP target so phones can ship transport
    # / volume controls to the sink on a best-effort basis.
    services.pipewire.wireplumber.extraConfig."10-bierkistn" = {
      "monitor.bluez.properties" = {
        "bluez5.roles" = [ "a2dp_sink" ];
        "bluez5.auto-connect" = [ ];
        "bluez5.enable-sbc-xq" = true;
        "bluez5.dummy-avrcp-player" = true;
      };
      "monitor.bluez.rules" = [{
        matches = [{
          "device.name" = "~bluez_card.*";
        }];
        actions = {
          "update-props" = {
            "device.profile" = "a2dp-sink";
          };
        };
      }];
    };

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
      };
      openFirewall = true;
    };

    # Under the cage kiosk there is no graphical session and no audio client at
    # boot, so pipewire's socket-activation never fires and wireplumber (which
    # BindsTo pipewire.service) stays dead. That means no A2DP-sink profile is
    # ever registered and phones pair but can't connect. Force the audio stack
    # to start with the user session so the bluetooth sink is always available.
    systemd.user.services = {
      pipewire.wantedBy = [ "default.target" ];
      wireplumber.wantedBy = [ "default.target" ];
    };

    # Pull the bierkistn Home Module in for every user with a home-manager
    # configuration (runs spotifyd as a user service).
    home-manager.sharedModules = [
      inputs.self.modules.homeManager.bierkistn
    ];

    environment.etc."spotifyd.conf".text = ''
      [global]
      use_mpris = true
      device_name = "${config.networking.hostName}"
      device_type = "speaker"
      bitrate = 320
      disable_discovery = false
      zeroconf_port = 57622
    '';

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "kistn" && (
          action.id.indexOf("org.freedesktop.NetworkManager.") === 0 ||
          action.id.indexOf("org.freedesktop.login1.") === 0 ||
          action.id.indexOf("org.bluez.") === 0
        )) {
          return polkit.Result.YES;
        }
      });
    '';

  };

  # Home Module bierkistn: run spotifyd as spotifyd.service for app-controlled source switching, started via default.target and recoverable on crashes
  flake.modules.homeManager.bierkistn = { pkgs, ... }: {
    systemd.user.services.spotifyd = {
      Unit = {
        Description = "spotifyd — Spotify playing daemon";
        After = [ "default.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path /etc/spotifyd.conf --cache-path %h/.cache/spotifyd";
        # An explicit systemctl --user stop is intentional during source
        # changes; on-failure still recovers crashes without restarting a
        # successfully stopped unit.
        Restart = "on-failure";
        RestartSec = 12;
      };
    };
  };
}
