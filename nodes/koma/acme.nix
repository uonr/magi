{ config, ... }:

{
  sops.secrets.cloudflare-yuru_me = {
    format = "binary";
    sopsFile = ../../secrets/cloudflare-yuru.me;
  };
  security.acme.certs."yuru.me" = {
    group = "nginx";
    dnsProvider = "cloudflare";
    extraDomainNames = [ "*.yuru.me" ];
    credentialsFile = config.sops.secrets.cloudflare-yuru_me.path;
  };
}
