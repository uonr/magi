{ pkgs, config, ... }:
let
  root = "/srv/ioover.net/";
  issoSettings = {
    general = {
      dbpath = "/var/lib/isso/ioover.net.db";
      host = "https://ioover.net";
      notify = "smtp";
      gravatar = "true";
      gravatar-url = "https://www.gravatar.com/avatar/{}?d=identicon";
    };
    admin = {
      enabled = false;
    };
    moderation = {
      enabled = true;
    };
    server = {
      listen = "http://127.0.0.1:8765";
    };
    smtp = {
      username = "postmaster@noreply.ioover.net";
      host = "smtp.mailgun.org";
      port = "587";
      security = "starttls";
      to = "comments@ioover.net";
      from = ''ioover.net" <comments@noreply.ioover.net>'';
    };
  };
in
{
  system.activationScripts.createBlogSourceDirectory = ''
    mkdir -p ${root}
    chown -R nginx:nginx ${root}
  '';
  services.nginx.enable = true;
  services.nginx.virtualHosts."ioover.net" = {
    forceSSL = true;
    enableACME = true;
    root = root;
    locations."/isso" = {
      proxyPass = "http://127.0.0.1:8765";
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Script-Name /isso;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
    locations."/pantry" = {
      return = "418";
    };
    locations."/" = {
      index = "index.html index.htm";
      tryFiles = "$uri $uri/ =404";
    };
    extraConfig = ''
      error_page 404 /404.html;
      error_page 418 /418.html;
    '';
  };

  services.isso = {
    enable = true;
    settings = issoSettings;
  };

  sops.secrets.borg-key-ioover_net = {
    format = "binary";
    sopsFile = ../../secrets/borg/lime.ioover.net;
  };
  services.borgbackup.jobs = {
    ioover_net = {
      paths = [ "/var/lib/isso" ];
      doInit = true;
      repo =  "borg@${config.backupHost}:." ;
      encryption = {
        mode = "none";
      };
      environment = import ../../modules/borg-env.nix { keyPath = config.sops.secrets.borg-key-ioover_net.path; };
      compression = "auto,lzma";
      startAt = "hourly";
    };
  };

  users.users.blog = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.sshKeys; 
  };


  networking.firewall.allowedTCPPorts = [ 873 ];
  services.rsyncd = {
    enable = true;
    settings = {
      blog = {
        uid = "nginx";
        gid = "nginx";
        "use chroot" = true;
        "read only" = false;
        path = root;
        "hosts allow" = "10.110.100.0/24";
      };
    };
  };
}
