{ pkgs, lib, boluo-server, config, ... }:
with lib;
let
  uid = 65220;
  gid = uid;
  postgres = pkgs.postgresql_13;
  cfg = config.services.boluo;
in {

  options.services.boluo = {
    enable = mkEnableOption "boluo";
    serverPort = mkOption {
      type = types.str;
      default = "3000";
    };
    serverName = mkOption {
      type = types.str;
    };
    serverAliases = mkOption {
      type = types.listOf types.str;
      default = [
      ];
    };
    enableACME = mkOption { type = types.bool; default = false; };
    secret = mkOption { type = types.str; };
    nginxSettings = {
      sslCertificate = mkOption { type = types.str; };
      sslCertificateKey = mkOption { type = types.str; };
      sslTrustedCertificate = mkOption { type = types.str; };
    };
  };

  config = mkIf cfg.enable {
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
        PORT = cfg.serverPort;
        REDIS_URL = "redis://127.0.0.1/";
        HOST = "0.0.0.0";
        DATABASE_URL = "postgresql://boluo@%%2Fvar%%2Frun%%2Fpostgresql/boluo";
        SYSTEMD = "1";
        DUMMY = "2";
        RUST_BACKTRACE = "1";
        MEDIA_PATH = "/var/lib/boluo/media/";
        SECRET = cfg.secret;
      };
    };
    services.redis.enable = true;
    services.nginx.recommendedTlsSettings = true;
    services.nginx.recommendedProxySettings = true;
    services.nginx.virtualHosts.${cfg.serverName} = cfg.nginxSettings // {
      serverName = cfg.serverName;
      serverAliases = cfg.serverAliases;
      forceSSL = true;
      enableACME = cfg.enableACME;
      root = pkgs.fetchzip {
          url = "https://github.com/mythal/boluo/releases/latest/download/boluo.zip";
          sha256 = "t1/erSgm0G5elB9e0XAt13CNxMLUbIMUQw+DFyxPlXQ=";
      };
      locations."/api" = {
        proxyPass = "http://127.0.0.1:${cfg.serverPort}";
      };
      locations."/api/events/connect" = {
        proxyPass = "http://127.0.0.1:${cfg.serverPort}";
        proxyWebsockets = true;
      };
      locations."/" = {
        tryFiles = "$uri $uri/ /index.html";
      };
    };
  };
}
