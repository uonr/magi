{ lib, config, ... }:
with lib;
{
  options.networking.bbr.enable = mkEnableOption "enable BBR";
  config = mkIf config.networking.bbr.enable {
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  };
}
