{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home.nix
  ];
  programs.git = {
    userName = "Tachibana Kiyomi";
    userEmail = "me@yuru.me";
  };
}
