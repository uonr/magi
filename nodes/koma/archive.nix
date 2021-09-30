{ pkgs, lib, config, ... }:
let 
  uid = 845;
  gid = 845;
  port = "3295";
in {
  users.users.archive = {
    isSystemUser = true;
    uid = uid;
    home = "/state/archive/";
    group = "archive";
  };
  system.activationScripts.archiveInit.text = ''
    mkdir -p /state/archive
    chown -R ${toString uid}:${toString gid} /state/archive
  '';
  users.groups.archive = { name = "archive"; members = ["archive"]; gid = gid; };
  services.ddclient.domains = [ "archive.yuru.me" ];
  services.nginx.virtualHosts."archive.yuru.me" = config.cert.yuru_me.nginxSettings // {
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
    };
  };
  virtualisation.oci-containers.containers = {
    archivebox = {
      autoStart = true;
      image = "archivebox/archivebox";
      ports = ["${port}:8000"];
      extraOptions = ["--pull=always"];
      environment = {
        PUID = toString uid;
        PGID = toString gid;
        SAVE_GIT = "False";
        SAVE_MERCURY = "False";
        SAVE_WARC = "False";
        SAVE_READABILITY = "False";
      };
      volumes = [
        "/state/archive/:/data"
      ];
    };
  };
}
