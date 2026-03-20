{ ... }: {
  # System Module docker: enable Docker daemon with Google DNS and add all users in the users specialArg to the docker group
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

  # System Module vm: enable VirtualBox with extension pack and guest additions for running virtual machines
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

  # System Module winboat: enable QEMU/libvirt with SPICE USB redirection and virt-manager for Windows VMs
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
