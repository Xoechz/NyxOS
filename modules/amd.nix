# settings for AMD gpus
{ pkgs, ... }: {
  hardware.graphics.enable = true;

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocmPackages.clr.icd
  ];

  hardware.opengl = {
    # Mesa
    enable = true;

    # Vulkan
    driSupport = true;
  };

  # For 32 bit applications 
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];
  hardware.opengl.driSupport32Bit = true;
}
