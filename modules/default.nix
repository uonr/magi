{ lib, pkgs, ... }:
with lib;
let
  utils = import ./utils.nix { inherit pkgs; };
  aliases = import ./aliases.nix;
in {
  imports = [
    ./wired.nix
    ./bbr.nix
    ./nix.nix
    ./ssh.nix
    ./webserver.nix
    ./vscode-server.nix
  ];
  options.backupHost = mkOption { type = types.str; default = "10.110.100.2"; };
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    programs.neovim = {
      defaultEditor = true;
      enable = true;
      viAlias = true;
      vimAlias = true;
      configure.packages.myVimPackage.start = import ./vim-plugins.nix { inherit pkgs; };
      configure.customRC = builtins.readFile ../share/config.vim;
    };
    programs.fish.shellAliases = aliases;
    programs.zsh.shellAliases = aliases;
    programs.bash.shellAliases = aliases;
    environment.systemPackages = with pkgs; utils ++ [
      btop
      unar
      killall
      gnupg
      pinentry-curses
      deploy-rs.deploy-rs
    ];
    programs.fish.enable = true;
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
    environment.variables.PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
  };
}
