# Shared SD-card image builder for NyxOS Pi hosts.
#
# Wraps any *host* NixOS module (nixPi or piKistn) into a bootable Raspberry Pi
# SD image using the nixpkgs sd-image-aarch64 builder. Reduces per-host duplication:
# both hosts declare only their own module + hostArgs; the image glue lives here.
{ inputs, ... }:
let
  buildSdImage = { hostModule, hostArgs, extraModules ? [ ] }:
    let
      system = "aarch64-linux";
      imgSystem = inputs.nixpkgs.lib.nixosSystem
        {
          inherit system;
          # hostArgs inherit `system` from the perSystem block (x86_64-linux), but the
          # target hostPlatform is aarch64-linux. Force `system` to match the image so
          # modules that branch on it (e.g. nix.nix's binfmt emulation) behave correctly.
          specialArgs = hostArgs // { inherit system; };
          modules = [
            hostModule
            inputs.home-manager.nixosModules.home-manager
            ({ modulesPath, ... }: {
              # nixpkgs' official sd-image builder: FIRMWARE (u-boot/config.txt) + ext4 root
              imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];
            })
          ] ++ extraModules;
        };
    in
    imgSystem.config.system.build.sdImage;
in
{
  perSystem = { system, lib, ... }: lib.mkIf (system == "x86_64-linux") {
    # Build host is the x86_64 laptop (EliasPC); each derivation cross-compiles aarch64
    # content natively (nixpi's pi4-system sets buildPlatform = x86_64-linux).
    packages.nixpi-sd-image = buildSdImage {
      hostModule = inputs.self.modules.nixos.nixPi;
      hostArgs = {
        inherit system;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        swapSize = 8; # GB
        users = [ "elias" ];
      };
    };
    packages.pikistn-sd-image = buildSdImage {
      hostModule = inputs.self.modules.nixos.piKistn;
      hostArgs = {
        inherit system;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        swapSize = 8; # GB
        users = [ "kistn" ];
      };
    };
  };
}
