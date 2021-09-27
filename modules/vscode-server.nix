# VSCode remote access workaround
#
# see
# https://nixos.wiki/wiki/Vscode
# https://github.com/msteen/nixos-vscode-server
{ config, lib, ... }:
let 
  nixos-vscode-server = fetchTarball {
    url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
    sha256 = "14zqbjsm675ahhkdmpncsypxiyhc4c9kyhabpwf37q6qg73h8xz5";
  };
in {
  imports = [
    nixos-vscode-server
  ];
}
