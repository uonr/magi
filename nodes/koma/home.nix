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
    signing.key = "FFF6DDE2181C1F55E8885470C02D23F17563AA95";
  };
}
