# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./reverse-proxy.nix
      ./play_trpg.nix
    ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Set your time zone.
  time.timeZone = "UTC";

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [ config.sshKey ];
  users.users.mikan = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ config.sshKey ];
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
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
  users.users.root.shell = pkgs.zsh;
  users.users.mikan.shell = pkgs.zsh;
  home-manager.users.root = import ./home.nix;
  home-manager.users.mikan = import ./home.nix;
  services.wired.enable = true;
  services.vscode-server.enable = true;
  networking.firewall.enable = true;
  networking.bbr.enable = true;
  services.nginx.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.dnsname.enable = true;
    };
    oci-containers.backend = "podman";
    docker.enable = false;
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

