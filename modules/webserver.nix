{ ... }: {
  services.nginx = {
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
  security.acme.email = "acme@yuru.me";
  security.acme.acceptTerms = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
