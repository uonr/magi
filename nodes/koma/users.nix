{ config, pkgs, ... }:

{
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [ config.sshKey ];
  users.users.mikan = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ config.sshKey ];
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "disk" "systemd-journal" ]; # Enable ‘sudo’ for the user.
  };
  users.users.root.shell = pkgs.zsh;
  users.users.mikan.shell = pkgs.zsh;
  home-manager.users.root = { ... }: {
    imports = [ ../../modules/home.nix ];
  };
  home-manager.users.mikan = import ./home.nix;
  security.sudo.extraRules = [
    {
      users = [ "mikan" ];
      commands = [
        {
          command = "ALL" ;
          options= [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}
