{ pkgs, ... }:

# options https://daiderd.com/nix-darwin/manual/index.html#sec-options
{
  imports = [
  ];
  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = true;
  };
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
  home-manager.users.mikan = { pkgs, ... }:
  let 
    utils = import ../../modules/utils.nix { inherit pkgs; };
  in {
    imports = [
      ../../modules/home.nix
    ];
    home.packages = with pkgs; utils ++ [
      htop
    ];
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = import ../../modules/vim-plugins.nix { inherit pkgs; };
      extraConfig = builtins.readFile ../../share/config.vim;
    };
    programs.git = {
      userName = "Tachibana Kiyomi";
      userEmail = "me@yuru.me";
      signing.key = "FFF6DDE2181C1F55E8885470C02D23F17563AA95";
    };
  };
}
