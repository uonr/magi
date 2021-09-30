{ pkgs, lib, config, ... }:
let 
  uid = 9001;
  gid = 9001;
  port = "3231";
in {
  users.users.manga = {
    isSystemUser = true;
    uid = uid;
    home = "/state/manga/";
    group = "manga";
  };
  system.activationScripts.mangaInit.text = ''
    mkdir -p /state/manga/content
    mkdir -p /state/manga/database
    chown -R ${toString uid}:${toString gid} /state/manga
  '';
  users.groups.manga = { name = "manga"; members = ["manga"]; gid = gid; };
  # services.ddclient.domains = [ "manga.yuru.me" ];
  services.nginx.virtualHosts."manga.yuru.me" =
  let
    certDir = config.security.acme.certs."yuru.me".directory;
  in {
    sslCertificate = "${certDir}/fullchain.pem";
    sslCertificateKey = "${certDir}/key.pem";
    sslTrustedCertificate = "${certDir}/chain.pem";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
      extraConfig = ''client_max_body_size 1024m;'';
      proxyWebsockets = true;
    };
  };
  virtualisation.oci-containers.containers = {
     lanraragi = {
       autoStart = true;
       image = "difegue/lanraragi:nightly";
       ports = ["${port}:3000"];
       extraOptions = ["--pull=always"];
       environment = {
         LRR_UID = toString uid;
         LRR_GID = toString gid;
       };
       volumes = [
         "/state/manga/content:/home/koyomi/lanraragi/content"
         "/state/manga/database:/home/koyomi/lanraragi/database"
       ];
     };
  };
}
