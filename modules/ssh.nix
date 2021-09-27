{ ... }: {
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    ports = [ 22 ];
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
  programs.mosh = {
    enable = true;
  };
}
