{ pkgs, lib, boluo-server, config, ... }:
let
  uid = 65220;
  gid = uid;
  serverPort = "3000";
  postgres = pkgs.postgresql_13;
in {

  users.users.boluo = {
    isSystemUser = true;
    uid = uid;
    home = "/var/lib/boluo";
    createHome = true;
    group = "boluo";
  };
  users.groups.boluo = { name = "boluo"; members = [ "boluo" ]; gid = gid; };
  services.nginx.enable = true;
  services.postgresql = {
    enable = true; 
    package = postgres;
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

  sops.secrets.borg-passphrase-boluo = {
    owner = "boluo";
    group = "boluo";
    format = "binary";
    sopsFile = ../../secrets/borg/lime.borg.passphrase.boluo;
  };
  sops.secrets.borg-key-boluo = {
    owner = "boluo";
    group = "boluo";
    format = "binary";
    sopsFile = ../../secrets/borg/lime.boluo.chat;
  };
  services.borgbackup.jobs = {
    boluo = {
      paths = [ "/var/lib/boluo" "/tmp/boluo.db.dump" ];
      user = "boluo";
      group = "boluo";
      repo =  "borg@${config.backupHost}:.";
      preHook = "${postgres}/bin/pg_dump boluo > /tmp/boluo.db.dump";
      environment = {
        BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile /dev/null' -i ${config.sops.secrets.borg-key-boluo.path}";
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
      };
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets.borg-passphrase-boluo.path}";
      };
      compression = "auto,lzma";
      startAt = "hourly";
    };
  };
}
