# configures dev packages
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # docker
    dive
  ];

  # enable docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [ "8.8.8.8" "8.8.4.4" ];
    };
  };

  users.extraGroups.docker.members = [ "elias" ];
}
