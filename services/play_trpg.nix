{ pkgs, config, secrets, ... }:

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
    ARCHIVE_URL = "https://play.yuru.me/";
  };
in {
  system.activationScripts.playTrpg.text = ''
    chmod a+x ${home};
    mkdir -p ${home}/data
    mkdir -p ${home}/db
    chown -R ${toString uid}:${toString gid} ${home}/data
    chown -R ${toString uid}:${toString gid} ${home}/db
  '';
  services.ddclient.domains = [ "play.yuru.me" ];
  services.nginx.virtualHosts."play.yuru.me" = {
    serverAliases = [ "log.mythal.net" ];
    # addSSL = true;
    # enableACME = true;
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
    sopsFile = "${secrets}/play_trpg";
  };
  # sops.secrets.borg-key-play_trpg = {
  #   owner = "play_trpg";
  #   group = "play_trpg";
  #   format = "binary";
  #   sopsFile = "${secrets}/borg/sage.play_trpg";
  # };
  # services.borgbackup.jobs = {
  #   play_trpg = {
  #     paths = [ "${home}/data" "/tmp/play_trpg.db.dump" ];
  #     user = "play_trpg";
  #     group = "play_trpg";
  #     repo =  "borg@${config.backupHost}:.";
  #     preHook = "${postgres}/bin/pg_dump play_trpg > /tmp/play_trpg.db.dump";
  #     environment = import ../../modules/borg-env.nix { keyPath = config.sops.secrets.borg-key-play_trpg.path; };
  #     encryption = {
  #       mode = "none";
  #     };
  #     compression = "auto,lzma";
  #     startAt = "hourly";
  #   };
  # };
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

