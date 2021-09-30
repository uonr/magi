# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  sshKey = config.sshKey;
in {
  imports =
    [
      ./hardware-configuration.nix
      ./devices.nix
      ./graphic.nix
      ./users.nix
      ./manga.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "koma"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  services.vscode-server.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  services.yubikey-agent.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.wired.enable = true;
  services.nginx.enable = true;

  services.ddclient = {
    enable = true;
    interval = "1min";
    domains = [ "koma.yuru.me" ];
    use = "web, web=ipv6.whatismyip.akamai.com";
    protocol = "cloudflare";
    zone = "yuru.me";
    ipv6 = true;
  };
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

