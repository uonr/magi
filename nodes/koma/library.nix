{ pkgs, lib, config, ... }:

let 
  user = "mikan";
  group = "users";
  port = 8183;
  dataDir = "yuru-library";
in {
  services.nginx.virtualHosts."lib.yuru.me" = config.cert.yuru_me.nginxSettings // {
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''client_max_body_size 512m;'';
    };
  };
  # system.activationScripts.libraryInit.text = ''
  #   mkdir -p /var/lib/${dataDir}
  #   chown -R ${user}:${group} /var/lib/${dataDir}
  # '';
  services.calibre-web = {
    enable = true;
    user = user;
    # inherit dataDir;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
      calibreLibrary = "/state/library";
    };
    listen.ip = "127.0.0.1";
    listen.port = port;
  };
}
