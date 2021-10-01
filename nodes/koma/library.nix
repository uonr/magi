{ pkgs, lib, config, ... }:

let 
  uid = config.users.users.mikan.uid;
  gid = config.users.groups.users.gid;
  port = 8183;
in {
  services.nginx.virtualHosts."lib.yuru.me" = config.cert.yuru_me.nginxSettings // {
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''client_max_body_size 512m;'';
    };
  };

  containers.library = {
    autoStart = true;
    ephemeral = true;
    bindMounts.calibreLibrary = {
      hostPath = "/state/library";
      mountPoint = "/var/lib/library";
      isReadOnly = false;
    };
    bindMounts.calibreWeb = {
      hostPath = "/state/library/calibre-web";
      mountPoint = "/var/lib/calibre-web";
      isReadOnly = false;
    };
    config = { ... }:
    {
      users.users.mikan = {
        isNormalUser = true;
        uid = uid;
      };
      services.calibre-web = {
        enable = true;
        user = "mikan";
        options = {
          enableBookUploading = true;
          enableBookConversion = true;
          calibreLibrary = "/var/lib/library";
        };
        listen.ip = "127.0.0.1";
        listen.port = port;
      };
    };
  };
}
