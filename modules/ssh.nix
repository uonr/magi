{ lib, ... }:
with lib;
{
  options.sshKeys = mkOption {
    type = types.listOf types.str;
    default = with builtins; [ 
      (readFile ../share/ssh-kiyomi.gpg-agent.pub)
      (readFile ../share/ssh-kiyomi.yubikey-agent.pub)
    ];
  };
  config = {
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      ports = [ 22 ];
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
    };
    networking.firewall.allowedTCPPorts = [ 22 ];
    programs.mosh = {
      enable = false;
    };
  };
}
