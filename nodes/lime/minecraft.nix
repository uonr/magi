{ lib, pkgs, config, minecraft-telegram-bot, ... }:
let
  minecraftServerOverlay = self: super: {
    minecraft-server = super.minecraft-server.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar";
        # sha1 because that comes from mojang via api
        sha1 = "a16d67e5807f57fc4e550299cf20226194497dc2";
      };
    });
  };
in {
  nixpkgs.overlays = [ minecraftServerOverlay ];
  nixpkgs.config.allowUnfree = true;
  services.minecraft-server = {
    enable = true;
    eula = true;
    dataDir = "/var/lib/minecraft";
    package = pkgs.minecraft-server;
    openFirewall = true;
    jvmOpts = "-Xmx2048M -Xms1024M -XX:+UseG1GC";
  };
  systemd.services.minecraft-telegram-bot = {
    enable = true;
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      WorkingDirectory = "/var/lib/minecraft/";
      EnvironmentFile = config.sops.secrets.minecraftBotEnv.path;
      MemoryMax = "128M";
    };
    script = "${pkgs.minecraft-telegram-bot}/bin/bot.py";
    environment = {
      LOG_FILE_PATH = "/var/lib/minecraft/logs/latest.log";
      CHAT_TITLE = "炸魚禁止";
    };
  };
  sops.secrets.minecraftBotEnv = {
    format = "binary";
    sopsFile = ../../secrets/minecraft-bot;
  };
}
