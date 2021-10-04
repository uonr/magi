{ config, ... }:
let
  port = "39701";
  uid = 1481;
  gid = uid;
in {

  users.users.szuru = {
    isSystemUser = true;
    uid = uid;
    home = "/state/szuru/";
    group = "szuru";
  };
  users.groups.szuru = { name = "szuru"; members = ["szuru"]; gid = gid; };

  # services.ddclient.domains = [ "booru.yuru.me" ];
  services.nginx.virtualHosts."moe.yuru.me" = config.cert.yuru_me.nginxSettings // {
    # serverAliases = [ "booru.yuru.me" ];
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
      extraConfig = ''client_max_body_size 256m;'';
    };
  };
}
