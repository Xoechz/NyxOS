# settings for AMD GPUs - optimized for high performance
{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Enable GPU frequency boosting
  boot.extraModprobeConfig = ''
    options amdgpu gpu_sched_hw_submission=2
    options amdgpu ppfeature_mask=0xffffffff
  '';
}
