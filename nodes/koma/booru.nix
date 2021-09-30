{ config, ... }:
let
  port = "39701";
  uid = 1481;
  gid = uid;
in {
  services.ddclient.domains = [ "booru.yuru.me" ];
  services.nginx.virtualHosts."booru.yuru.me" = config.cert.yuru_me.nginxSettings // {
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
      extraConfig = ''client_max_body_size 256m;'';
    };
  };
}
