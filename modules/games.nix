{ ... }: {
  # System Module steam: enable Steam with Proton, Protontricks, MangoHud, Gamescope, and open firewall ports
  flake.modules.nixos.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = false;
      protontricks.enable = true;
    };

    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      xrdb
      xsettingsd
      gamescope
    ];
  };

  # Home Module minecraft: install ATLauncher for managing Minecraft modpacks
  flake.modules.homeManager.minecraft = { pkgs, ... }: {
    home.packages = with pkgs; [
      atlauncher
    ];
  };
}
