{
  description = "Deployment for my server cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
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
    secrets.url = git+ssh://git@github.com/uonr/magi-secrets.git;
    minecraft-telegram-bot.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay"; 
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    deploy-rs,
    home-manager,
    sops-nix,
    telegram-dice-bot,
    minecraft-telegram-bot,
    boluo-server,
    rust-overlay,
    secrets,
  }:
  with nixpkgs.lib;
  let 
    rustModule = { pkgs, ... }: {
      nixpkgs.overlays = [ rust-overlay.overlay ];
    };
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
      koma = {
        host = "10.110.100.2";
        system = "x86_64-linux";
      };
    };
    join = concatStringsSep "\n";
    hostsLine = hostname: { host, ... }: "${host}    ${hostname}";
    nodeToHost = mapAttrsToList hostsLine;
  in {
    darwinConfigurations."mithril" = darwin.lib.darwinSystem {
      specialArgs = { inherit secrets; };
      system = "x86_64-darwin";
      modules = [
        rustModule
        ./modules/nebula.nix
        sops-nix.nixosModule
        home-manager.darwinModule
        "${secrets}/nodes/mithril.nix"
        ./nodes/mithril/configuration.nix
      ];
    };
    nixosConfigurations = mapAttrs (hostname: { system, ... }: nixosSystem {
      inherit system;
      specialArgs = { inherit secrets; };
      modules = [
        telegram-dice-bot.nixosModule.${system}
        minecraft-telegram-bot.nixosModule.${system}
        {
          nixpkgs.overlays = [
            deploy-rs.overlay
            boluo-server.overlay.${system}
          ];
        }
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./modules
        ./nodes/${hostname}/configuration.nix
        "${secrets}/nodes/${hostname}.nix"
        {
          networking.hostName = hostname;
          networking.extraHosts = let
            filterSelf = name: { ... }: name != hostname;
            others = filterAttrs filterSelf nodes;
          in
            join (nodeToHost others);
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
