{ pkgs, ... }:

{
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # https://nixos.wiki/wiki/AMD_GPU
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
  ];
  # hardware.opengl.extraPackages32 = with pkgs; [
  #   driversi686Linux.amdvlk
  # ];
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
}
