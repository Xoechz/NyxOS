{ ... }: {
  flake-file.inputs = {
    bierkistn-radio = {
      url = "git+file:///home/elias/Repos/BierKistnRadio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System Module bierkistn: install the BierKistn Radio UI, spotifyd as a user service, always-discoverable A2DP-sink Bluetooth with best-effort AVRCP, and grant the kiosk user the D-Bus actions it needs
  flake.modules.nixos.bierkistn = { pkgs, config, ... }: {
    environment.systemPackages = with pkgs; [
      spotifyd
    ];

    # Base discoverable + pairable policy. bluez starts the adapter with
    # these persisted; Discoverable/PairableTimeout=0 means "never expire".
    # bluez drops Discoverable once a device connects — per ADR 0004 the app
    # re-asserts `Adapter1.Set(Discoverable, true)` on entering BluetoothWaiting,
    # so NO system enforcement service is needed.
    hardware.bluetooth.settings.General = {
      AutoEnable = true;
      Discoverable = true;
      DiscoverableTimeout = 0;
      Pairable = true;
      PairableTimeout = 0;
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

    # D-Bus: no policy file needed. BlueZ owns org.bluez on the system bus
    # (it has no session-bus option). Its stock policy
    # (share/dbus-1/system.d/bluetooth.conf) grants every user
    # send_destination=org.bluez, so the kiosk user can already call
    # Adapter1.Set/Device1.Disconnect and watch properties without additions.

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
      };
      openFirewall = true;
    };

    environment.etc."spotifyd.conf".text = ''
      [global]
      use_mpris = true
      device_name = "${config.networking.hostName}"
      device_type = "speaker"
      bitrate = 320
      disable_discovery = false
      zeroconf_port = 57622
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
