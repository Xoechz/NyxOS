{ ... }: {
  # System Module steam: configure steam and related tools
  flake.modules.nixos.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
      protontricks.enable = true;
    };

    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      xrdb
      xsettingsd
    ];
  };

  # Home Module minecraft: configure minecraft and related tools
  flake.modules.homeManager.minecraft = { pkgs, ... }: {
    home.packages = with pkgs; [
      atlauncher
    ];
  };
}
