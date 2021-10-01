{ lib, ... }:
with lib;
{
  imports = [
    ./wired.nix
    ./bbr.nix
    ./utils.nix
    ./aliases.nix
    ./neovim.nix
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
  };
}
