{ pkgs, config, secrets, ... }: 
let
  port = 8081;
  uid = 941;
  gid = 941;
  home = "/var/lib/mythal";
  h5ai = pkgs.fetchzip {
    url = "https://release.larsjung.de/h5ai/h5ai-0.30.0.zip";
    name = "h5ai";
    sha256 = "iKKSJg8twAP/ZFKbKsKn2ogyU3noENYTPGnx9zktFGc=";
  };
  wikiDbUser = "mythal_wiki";
  wikiDbName = "mythal_wiki";
  fourmDbUser = "boluo";
  forumDbName = "boluo_forum";
  wikiMaxBodySize = "128M";
  forumMaxBodySize = "128M";
  backupHost = config.backupHost;
  mysql = pkgs.mariadb;
in {
  users.users.mythal = {
    isNormalUser = true;
    uid = uid;
    home = home;
    group = "mythal";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFsBjZ9pRIKEZ7M3COFGOB89HsZWHnCqPoRer/4RuCz mikan@mithril.local"
    ];
  };
  users.groups.mythal = { name = "mythal"; members = ["mythal"]; gid = gid; };

  system.activationScripts.mythalInit = ''
    rm -rf ${home}/srv/files/_h5ai
    cp -r ${h5ai} ${home}/srv/files/_h5ai
    chown -R ${toString uid}:${toString gid} ${home}/srv/
  '';
  services.nginx = {
    enable = true;
    virtualHosts."files.mythal.net" = {
      serverAliases = [
        "file.mythal.net"
        "doc.mythal.net"
      ];
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
      };
    };

    virtualHosts."forum.boluo.chat" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
      };
      extraConfig = ''
        client_max_body_size ${forumMaxBodySize};
      '';
    };
  
    virtualHosts."wiki.mythal.net" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
      };
      extraConfig = ''
        client_max_body_size ${wikiMaxBodySize};
      '';
    };
  };

  sops.secrets.borg-key-mythal = {
    format = "binary";
    sopsFile = "${secrets}/borg/lime.mythal";
  };

  containers.mythal = {
    autoStart = true;

    bindMounts.sshKey = {
      hostPath = config.sops.secrets.borg-key-mythal.path;
      mountPoint = "/run/ssh-key";
      isReadOnly = true;
    };
    bindMounts."files" = {
      hostPath = "${home}/srv/files";
      mountPoint = "/srv/files";
    };

    bindMounts."forum" = {
      hostPath = "${home}/srv/forum";
      mountPoint = "/srv/forum";
      isReadOnly = false;
    };
    bindMounts."wiki" = {
      hostPath = "${home}/srv/wiki";
      mountPoint = "/srv/wiki";
      isReadOnly = false;
    };

    bindMounts."mysql" = {
      hostPath = "${home}/wiki_db";
      mountPoint = "/var/lib/mysql";
      isReadOnly = false;
    };
    config = { config, pkgs, ... }: {
      users.users.mythal = {
        isSystemUser = true;
        uid = uid;
        group = "mythal";
      };
      users.groups.mythal = { name = "mythal"; members = ["mythal"]; gid = gid; };
      environment.systemPackages = with pkgs; [
        wget
        unzip
        neovim
      ];
      services.mysql = {
        enable = true;
        package = mysql;
        ensureDatabases = [
          wikiDbName
          forumDbName
        ];
        ensureUsers = [
          {
            name = wikiDbUser;
            ensurePermissions = {
              "${wikiDbName}.*" = "ALL PRIVILEGES";
            };
          }
          {
            name = fourmDbUser;
            ensurePermissions = {
              "${forumDbName}.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };
      services.phpfpm = {
        phpPackage = pkgs.php74.withExtensions (
          { enabled, all }: with all; enabled ++ [
            imagick curl dom gd json mbstring openssl pdo_mysql tokenizer zip intl apcu xml fileinfo
          ]
        );
        pools.www = {                                                                                                                                                                                                             
          user = config.services.nginx.user;                                                                                                                                                                                                                           
          settings = {                                                                                                                                                                                                                               
            pm = "dynamic";            
            "listen.owner" = config.services.nginx.user;                                                                                                                                                                                                              
            "pm.max_children" = 5;                                                                                                                                                                                                                   
            "pm.start_servers" = 2;                                                                                                                                                                                                                  
            "pm.min_spare_servers" = 1;                                                                                                                                                                                                              
            "pm.max_spare_servers" = 3;                                                                                                                                                                                                              
            "pm.max_requests" = 500;                                                                                                                                                                                                                 
          };                                                                                                                                                                                                                                         
        };
      };
      services.nginx = {
        enable = true;
        user = "mythal";
        group = "mythal";
        virtualHosts."files.mythal.net" = {
          serverAliases = [
            "file.mythal.net"
            "doc.mythal.net"
          ];
          root = "/srv/files/";
          listen = [{
            addr = "127.0.0.1";
            port = port;
          }];
          extraConfig = ''
            index index.php index.html index.htm /_h5ai/public/index.php;
          '';
          locations."/" = {
            tryFiles = "$uri $uri/ /index.php =404";
          };
          locations."~ /.*\.php$" = {
            extraConfig = ''
              fastcgi_pass  unix:${config.services.phpfpm.pools.www.socket};
              fastcgi_index index.php;
            '';
          };
        };

        virtualHosts."forum.boluo.chat" = {
          listen = [{
            addr = "127.0.0.1";
            port = port;
          }];
          root = "/srv/forum/public";
          extraConfig = ''
            index index.php index.html index.htm;
            client_max_body_size ${forumMaxBodySize};
            include /srv/forum/.nginx.conf;
          '';


          locations."~ /.*\.php$" = {
            extraConfig = ''
              fastcgi_pass  unix:${config.services.phpfpm.pools.www.socket};
              fastcgi_index index.php;
            '';
          };
        };

        virtualHosts."wiki.mythal.net" = {
          root = "/srv/wiki/";
          listen = [{
            addr = "127.0.0.1";
            port = port;
          }];
          extraConfig = ''
            index index.php index.html index.htm;
            client_max_body_size ${wikiMaxBodySize};
          '';
          locations."/" = {
            tryFiles = "$uri $uri/ @rewrite";
          };

          locations."@rewrite" = {
            extraConfig = ''
              rewrite ^/(.*)$ /index.php?title=$1&$args;
            '';
          };

          # fix visual editor
          locations."/rest.php" = {
            tryFiles = "$uri $uri/ /rest.php?$args";
          };

          locations."~ \.php$" = {
            extraConfig = ''
              fastcgi_pass  unix:${config.services.phpfpm.pools.www.socket};
              fastcgi_index index.php;
            '';
          };

          locations."~* \.(js|css|png|jpg|jpeg|gif|ico)$" = {
            tryFiles = "$uri /index.php";
            extraConfig = ''
              expires max;
              log_not_found off;
            '';
          };

          locations."/dumps" = {
            extraConfig = ''
              root /srv/wiki/local;
              autoindex on;
            '';
          };
        };
      };

      services.borgbackup.jobs = {
        mythal = {
          paths = [ "/tmp/mythal.db.dump" "/srv/forum" "/srv/wiki" ];
          repo =  "borg@${backupHost}:.";
          preHook = "${pkgs.mysql}/bin/mysqldump --user root --all-databases > /tmp/mythal.db.dump";
          environment = import ../../modules/borg-env.nix { keyPath = "/run/ssh-key"; };
          encryption = {
            mode = "none";
          };
          compression = "auto,lzma";
          startAt = "hourly";
        };
      };

    }; # end of config
  }; # end of container


}
