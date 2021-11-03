# VSCode remote access workaround
#
# see
# https://nixos.wiki/wiki/Vscode
# https://github.com/msteen/nixos-vscode-server
{ config, lib, ... }:
let 
  nixos-vscode-server = fetchTarball {
    url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
    sha256 = "00aqwrr6bgvkz9bminval7waxjamb792c0bz894ap8ciqawkdgxp";
  };
in {
  imports = [
    nixos-vscode-server
  ];
}
