{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home.nix
  ];

  home.packages = with pkgs; [
    tdesktop
    google-chrome
    _1password-gui
    minecraft
    vscode
    obsidian
    steam
  ];
  programs.git = {
    userName = "Tachibana Kiyomi";
    userEmail = "me@yuru.me";
  };
}
