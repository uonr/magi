{ pkgs, lib, boluo-server, config, ... }:
let
  serverPort = "3000";
in {
  services.nginx.enable = true;
  services.postgresql = {
    enable = true; 
    package = pkgs.postgresql_13;
    ensureDatabases = [ "boluo" ];
    extraPlugins = with pkgs.postgresql13Packages; [ pg_rational ];
    ensureUsers = [
      {
        name = "boluo";
        ensurePermissions = {
          "DATABASE boluo" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.boluo-server = {
    requires = [ "network.target" "postgresql.service" "redis.service" ];
    wantedBy = [ "multi-user.target" ];
    description = "Boluo server";
    serviceConfig = {
      User = "boluo";
      Group = "boluo";
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "boluo";
      Restart = "on-failure";
      WorkingDirectory = "/var/lib/boluo/";
    };
    script = ''${pkgs.boluo-server}/bin/server'';
    environment = {
      DEBUG = "";
      PORT = serverPort;
      REDIS_URL = "redis://127.0.0.1/";
      HOST = "0.0.0.0";
      DATABASE_URL = "postgresql://boluo@%%2Fvar%%2Frun%%2Fpostgresql/boluo";
      SYSTEMD = "1";
      RUST_BACKTRACE = "1";
      MEDIA_PATH = "/var/lib/boluo/media/";
    };
  };
  services.redis.enable = true;
  services.rsyncd = {
    enable = true;
    # man rsyncd.conf
    settings = {
      boluo = {
        uid = "boluo";
        gid = "boluo";
        "use chroot" = true;
        "max connections" = 4;
        "hosts allow" = "154.31.112.74";
        "read only" = false;
        path = "/var/lib/boluo/";
      };
    };
  };
  services.nginx.recommendedTlsSettings = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."boluo.chat" = {
    serverName = "boluo.chat";
    serverAliases = [ "cdn.boluo.chat" "www.boluo.chat" ];
    forceSSL = true;
    enableACME = true;
    root = pkgs.fetchzip {
        url = "https://github.com/mythal/boluo/releases/latest/download/boluo.zip";
        sha256 = "NLd4AWmW357o7u4f97tLEPWIWfYxyvDZ+cgVgTyRdvU=";
    };
    locations."/api" = {
      proxyPass = "http://127.0.0.1:${serverPort}";
    };
    locations."/api/events/connect" = {
      proxyPass = "http://127.0.0.1:${serverPort}";
      proxyWebsockets = true;
    };
    locations."/" = {
      tryFiles = "$uri $uri/ /index.html";
    };
  };
}
