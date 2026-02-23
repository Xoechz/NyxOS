{ ... }: {
  # System Module docker: enable and configure docker for development
  flake.modules.nixos.docker = { pkgs, users, ... }: {
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

    users.extraGroups.docker.members = users;
  };

  # System Module vm: enable and configure virtual machine support for development
  flake.modules.nixos.vm = { users, ... }: {
    virtualisation.virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
      guest = {
        enable = true;
        dragAndDrop = true;
      };
    };

    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
    users.extraGroups.vboxusers.members = users;
  };

  # System Module winboat: enable and configure winboat for running windows in a vm
  flake.modules.nixos.winboat = { pkgs, users, ... }: {
    virtualisation = {
      spiceUSBRedirection.enable = true;
      libvirtd = {
        enable = true;
        package = pkgs.libvirt;
        qemu = {
          package = pkgs.qemu;
          swtpm = {
            enable = true;
          };
        };
      };
    };

    users.extraGroups.libvirtd.members = users;

    services.spice-vdagentd.enable = true;

    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      winboat
      freerdp
    ];
  };
}
