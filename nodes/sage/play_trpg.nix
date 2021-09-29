{ pkgs, config, ... }:

let
  port = "8885";
  uid = 9831;
  gid = uid;
  home = "/var/lib/play_trpg";
  environment = {
    DJANGO_SETTINGS_MODULE = "play_trpg.settings";
    POSTGRES_DB = "play_trpg";
    POSTGRES_USER = "play_trpg";
    REDIS_HOST = "127.0.0.1";
    PORT = port;
    ARCHIVE_URL = "https://log.mythal.net/";
  };
in {
  system.activationScripts.playTrpg.text = ''
    chmod a+x ${home};
    mkdir -p ${home}/data
    mkdir -p ${home}/db
    chown -R ${toString uid}:${toString gid} ${home}/data
    chown -R ${toString uid}:${toString gid} ${home}/db
  '';
  services.nginx.virtualHosts."log.mythal.net" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      extraConfig = ''
        uwsgi_pass 127.0.0.1:${port};
      '';
    };
    locations."/static/" = {
      alias = "${home}/data/static/";
    };
    locations."/media/" = {
      alias = "${home}/data/media/";
    };
  };
  users.groups.play_trpg = { gid = gid; };
  users.users.play_trpg = {
    isSystemUser = true;
    uid = uid;
    group = "play_trpg";
    home = home;
    createHome = true;
  };
  services.redis.enable = true;
  services.postgresql = {
    enable = true; 
    package = pkgs.postgresql_13;
    ensureDatabases = [ "play_trpg" ];
    ensureUsers = [
      {
        name = "play_trpg";
        ensurePermissions = {
          "DATABASE play_trpg" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  sops.secrets.playTrpgEnv = {
    format = "binary";
    sopsFile = ../../secrets/play_trpg;
  };
  virtualisation.oci-containers.containers = {
    playtrpg-bot = {
      image = "whoooa/play_trpg_bot:latest";
      cmd = [ "python" "start_bot.py" ];
      extraOptions = [ "--pull=always" "--network=host" ];
      user = "${toString uid}:${toString gid}";
      volumes = [
        "${home}/data:/code/data"
        "/var/run/postgresql/:/var/run/postgresql"
      ];
      inherit environment;
      environmentFiles = [
        config.sops.secrets.playTrpgEnv.path
      ];
    };
    playtrpg-web = {
      image = "whoooa/play_trpg_bot:latest";
      cmd = [ "uwsgi" "--ini" "deploy/uwsgi.ini" "--socket" "127.0.0.1:${port}" ];
      extraOptions = [ "--pull=always" "--network=host" ];
      user = "${toString uid}:${toString gid}";
      volumes = [
        "${home}/data:/code/data"
        "/var/run/postgresql/:/var/run/postgresql"
      ];
      inherit environment;
      environmentFiles = [
        config.sops.secrets.playTrpgEnv.path
      ];
    };
  };
}
