# darwin-nix options
# https://daiderd.com/nix-darwin/manual/index.html#sec-options

{ pkgs, ... }:

{
  imports = [
    ../../modules/wired.nix
  ];

  sops.gnupg.sshKeyPaths = [
    "/private/etc/ssh/ssh_host_rsa_key.pub"
  ];

  services.wired = {
    enable = true;
    # It seems like sops-nix does not create the /run/secrets/ path correctly in nix-darwin
    useSops = false;
    hostName = "mithril";
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = false;
  };
  nixpkgs.config.allowUnfree = true;
  nix = {
    # Ensure that flake support is enabled.
    package = pkgs.nixUnstable;
    gc = {
      automatic = true;
      interval = { Hour = 48; Minute = 0; };
      options = "--delete-older-than 8d";
    };
    trustedUsers = [ "root" "mikan" ];
    allowedUsers = [ "root" "mikan" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.zsh.enable = true;
  services.skhd.enable = false;
  services.redis.enable = false;

  services.postgresql.enable = false;
  services.nix-daemon.enable = true;
  environment.systemPackages = [];
  users.users.mikan = {
    name = "mikan";
    home = "/Users/mikan";
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.mikan = import ./home.nix;
}
