{ pkgs, ... }: {
  # Module elias: user configuration for elias
  flake.modules.nixos.elias = {
    users.users.elias = {
      isNormalUser = true;
      description = "Elias";

      # lpadmin is needed for printer setup
      # video is needed for dvb-s access
      extraGroups = [ "networkmanager" "wheel" "lpadmin" "video" ];
      shell = pkgs.zsh;

      # To generate SSH keys:#
      # elias:
      # ssh-keygen -t ed25519 -N ""
      # cat ~/.ssh/id_ed25519.pub
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTZwgrSgkHT3WWJYIIe+dSvArtbp5JFetu6WpR5KC9t elias@EliasPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL71xmI34J5TlOzo6z0M3kTpzUTB7jxqiEvkALg4bcC6 root@EliasPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8x7bIB+Ai92GiQ/m6SzFdUODBW0chhmwC0OERjofTi elias@EliasLaptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDhjGdO4LZSBd21DrYSt1iJAC5f1kP1Q9yleTf9qZ7o root@EliasLaptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEkkeMQneWIvzI9mzolIl2nyzt7pnzHqlNfk4zDlPyw elias@NixPi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF/LtEbMhHudYUlzGlYi3gdO819/U5KC1aJ5XNSkRJi root@NixPi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTsxwG/oZFKPLTH1SBVewZnWUaFJs9F+2o2SttnNv2j elias@FredPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWvZfUNVpUiiNM5ZWm7gExARtj/LXKADUGwnh/XuaNe root@FredPC"
      ];
    };
  };

  # Module others: user configuration for fred and gerhard
  flake.modules.nixos.others = {
    users.users = {
      fred = {
        isNormalUser = true;
        description = "Fred";
        # lpadmin is needed for printer setup
        # video is needed for dvb-s access
        extraGroups = [ "networkmanager" "wheel" "lpadmin" "video" ];
      };
      gerhard = {
        isNormalUser = true;
        description = "Gerhard";
        # lpadmin is needed for printer setup
        # video is needed for dvb-s access
        extraGroups = [ "networkmanager" "wheel" "lpadmin" "video" ];
      };
    };
  };

  # Module eliasHome: home manager configuration for elias
  flake.modules.home-manager.eliasHome = {
    home.username = "elias";
    home.homeDirectory = "/home/elias";
  };

  # Module fredHome: home manager configuration for fred
  flake.modules.home-manager.fredHome = {
    home.username = "fred";
    home.homeDirectory = "/home/fred";
  };

  # Module gerhardHome: home manager configuration for gerhard
  flake.modules.home-manager.gerhardHome = {
    home.username = "gerhard";
    home.homeDirectory = "/home/gerhard";
  };
}
