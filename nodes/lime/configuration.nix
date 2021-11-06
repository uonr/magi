# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./minecraft.nix
      ./dns.nix
      ./netdata.nix
      ./ioover.net.nix
      ./boluo.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.device = "/dev/vda";

  networking.bbr.enable = true;

  # Set your time zone.
  time.timeZone = "UTC";

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = config.sshKeys;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = config.sshKeys;
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
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  home-manager.users.mikan = import ./home.nix;
  home-manager.users.root = import ./home.nix;

  services.wired.enable = true;
  services.nginx.enable = true;
  swapDevices = [
    {
      device = "/var/swap";
      size = 1024 * 4; # twice the RAM should leave enough space for hibernation
    }
  ];


  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}

