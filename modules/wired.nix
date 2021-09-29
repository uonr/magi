{ lib, config, ... }: 
with lib;
let
  cfg = config.services.wired;
in {
  options.services.wired = {
    enable = mkEnableOption "wired nebula network service";
    hostName = mkOption {
      type = types.str;
      default = config.networking.hostName;
    };
    isLighthouse = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.nebulaKey = {
      format = "binary";
      sopsFile = ../secrets/nebula/${cfg.hostName}.key;
    };
    networking.firewall.allowedUDPPorts = [ 4242 ];
    services.nebula.networks.wired = {
      enable = true;
      isLighthouse = cfg.isLighthouse;
      key = config.sops.secrets.nebulaKey.path;
      ca = ../secrets/nebula/ca.crt;
      cert = ../secrets/nebula/${cfg.hostName}.crt;
      lighthouses = if cfg.isLighthouse then [] else [ "10.110.1.1" "10.110.1.2" ];
      staticHostMap = {
        "10.110.1.1" = [ "154.31.112.93:4242" ];
        "10.110.1.2" = [ "35.200.108.79:1121" ];
      };
      firewall.outbound = [
        { port = "any"; proto = "any"; host = "any"; }
      ];
      firewall.inbound = [
        { port = "any"; proto = "any"; host = "any"; }
      ];
    };
  };
}
