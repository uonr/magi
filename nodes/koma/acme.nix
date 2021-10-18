{ config, lib, secrets, ... }:

with lib;
{
  options.cert.yuru_me.nginxSettings = {
    sslCertificate = mkOption { type = types.str; };
    sslCertificateKey = mkOption { type = types.str; };
    sslTrustedCertificate = mkOption { type = types.str; };
  };

  config = {
    cert.yuru_me.nginxSettings = let 
      certDir = config.security.acme.certs."yuru.me".directory;
    in {
      sslCertificate = "${certDir}/fullchain.pem";
      sslCertificateKey = "${certDir}/key.pem";
      sslTrustedCertificate = "${certDir}/chain.pem";
    };
    sops.secrets.cloudflare-yuru_me = {
      format = "binary";
      sopsFile = "${secrets}/cloudflare-yuru.me";
    };
    security.acme.certs."yuru.me" = {
      group = "nginx";
      dnsProvider = "cloudflare";
      extraDomainNames = [ "*.yuru.me" ];
      credentialsFile = config.sops.secrets.cloudflare-yuru_me.path;
    };
  };
}
