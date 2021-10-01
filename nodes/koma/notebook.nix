{ pkgs, lib, config, ... }:

let 
  uid = 9231;
  gid = 9231;
  port = 8231;
in {
  services.nginx.virtualHosts."note.yuru.me" = config.cert.yuru_me.nginxSettings // {
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''client_max_body_size 512m;'';
    };
  };
  services.trilium-server = {
    enable = true;
    port = port;
    instanceName = "wani";
    dataDir = "/state/wani";
  };
}
