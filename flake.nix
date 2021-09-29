{
  description = "Deployment for my server cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    telegram-dice-bot.url = github:mythal/telegram-dice-bot;
    telegram-dice-bot.inputs.nixpkgs.follows = "nixpkgs";
    boluo-server.url = github:mythal/boluo-server;
    boluo-server.inputs.nixpkgs.follows = "nixpkgs";
    minecraft-telegram-bot.url = github:uonr/minecraft-telegram-bot;
    minecraft-telegram-bot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-rs, home-manager, sops-nix, telegram-dice-bot, minecraft-telegram-bot, boluo-server }:
  with nixpkgs.lib;
  let 
    nodes = {
      sage = {
        host = "10.110.100.5";
        system = "x86_64-linux";
      };
      lily = {
        host = "10.110.100.7";
        system = "x86_64-linux";
      };
      lime = {
        host = "10.110.1.1";
        system = "x86_64-linux";
      };
    };
  in {
    nixosConfigurations = mapAttrs (hostname: { system, ... }: nixosSystem {
      inherit system;
      modules = [
        telegram-dice-bot.nixosModule.${system}
        minecraft-telegram-bot.nixosModule.${system}
        {
          nixpkgs.overlays = [
            (final: prev: {
              boluo-server = boluo-server.defaultPackage.${system};
            })
          ];
        }
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./modules
        ./nodes/${hostname}/configuration.nix
        {
          networking.extraHosts = let
            join = concatStringsSep "\n";
            hostsLine = hostname: { host, ... }: "${host}    ${hostname}";
            filterSelf = name: { ... }: name != hostname;
            otherHosts = filterAttrs filterSelf nodes;
            hostsLines = mapAttrsToList hostsLine otherHosts;
          in
            join hostsLines;
        }
      ];
    }) nodes;
    deploy.nodes = mapAttrs (hostname: { host, system, ... }: {
      sshUser = "root";
      hostname = host;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
      };
    }) nodes;

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
