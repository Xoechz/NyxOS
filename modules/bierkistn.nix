{ inputs, ... }: {
  flake-file.inputs = {
    bierkistn-radio = {
      url = "github:Xoechz/BierKistnRadio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System Module bierkistn: install the BierKistn Radio UI, always-discoverable A2DP-sink Bluetooth with best-effort AVRCP, grant the kiosk user the D-Bus actions it needs, and pull in the bierkistn Home Module for all users
  flake.modules.nixos.bierkistn = { pkgs, config, ... }: {
    environment.systemPackages = with pkgs; [
      spotifyd
      bluez-tools
      ddcutil
      i2c-tools
    ];

    # Auto-accept pairing without PIN/code checks: bt-agent runs with the
    # NoInputNoOutput capability, which answers every pairing request
    # affirmatively (the kiosk has no display/keyboard to enter a code).
    systemd.services.bt-agent = {
      wantedBy = [ "bluetooth.target" ];
      after = [ "bluetooth.service" ];
      description = "Bluetooth pairing agent (auto-accept)";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bluez-tools}/bin/bt-agent --capability NoInputNoOutput";
        Restart = "always";
        RestartSec = 5;
      };
    };

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
          action.id.indexOf("org.freedesktop.login1.") === 0
        )) {
          return polkit.Result.YES;
        }
      });
    '';

    # brightness control via DDC/CI (requires ddcutil)
    hardware.i2c.enable = true;
  };

  # Home Module bierkistn: run spotifyd as a user service on the A2DP sink, started via default.target (no graphical-session dependency under cage)
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
        Restart = "always";
        RestartSec = 12;
      };
    };
  };
}
