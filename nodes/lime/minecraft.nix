{ lib, pkgs, config, minecraft-telegram-bot, secrets, ... }:
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
  services.minecraft-telegram-bot = {
    enable = true;
    logFilePath = "/var/lib/minecraft/logs/latest.log";
    chatTitle = "炸魚禁止";
    environmentFile = config.sops.secrets.minecraftBotEnv.path;
  };
  sops.secrets.minecraftBotEnv = {
    format = "binary";
    sopsFile = "${secrets}/minecraft-bot";
  };

  sops.secrets.borg-key-minecraft = {
    format = "binary";
    sopsFile = "${secrets}/borg/lime.minecraft";
  };
  services.borgbackup.jobs = {
    minecraft = {
      paths = [ "/var/lib/minecraft" ];
      doInit = true;
      repo =  "borg@${config.backupHost}:.";
      encryption = {
        mode = "none";
      };
            environment = import ../../modules/borg-env.nix { keyPath = config.sops.secrets.borg-key-minecraft.path; };
      compression = "auto,lz4";
      startAt = "daily";
    };
  };
}
