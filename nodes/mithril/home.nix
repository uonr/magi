# Home Manager options
# https://nix-community.github.io/home-manager/options.html

{ pkgs, ... }:
let 
  utils = import ../../modules/utils.nix { inherit pkgs; };
  sshKey = builtins.readFile ../../share/ssh-kiyomi.gpg-agent.pub;
in {
  imports = [
    ../../modules/home.nix
  ];
  home.aliases = {
    top = "htop";
  };
  home.packages = with pkgs; utils ++ [
    htop
    gnupg
    yarn
    python3
    youtube-dl
    rustup
    nodejs-16_x
    nodePackages.pnpm
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = import ../../modules/vim-plugins.nix { inherit pkgs; };
    extraConfig = builtins.readFile ../../share/config.vim;
  };
  programs.ssh = let
    kiyomi = pkgs.writeTextFile {
      name = "kiyomi.pub";
      text = sshKey;
    };
  in {
    enable = true;
    matchBlocks = {
      koma = {
        hostname = "10.110.100.2";
        user = "mikan";
        extraOptions = let 
          gpgHome = "/Users/mikan/.gnupg";
          target = "/run/user/1000/gnupg";
        in {
          "RemoteForward ${target}/S.gpg-agent" = "${gpgHome}/S.gpg-agent";
          "RemoteForward ${target}/S.gpg-agent.ssh" = "${gpgHome}/S.gpg-agent.ssh";
        };
      };

      "*" = {
        identityFile = [
          "${kiyomi}"
        ];
      };
    };
  };
  programs.git = {
    userName = "Tachibana Kiyomi";
    userEmail = "me@yuru.me";
    signing.key = "FFF6DDE2181C1F55E8885470C02D23F17563AA95";
  };
  home.file = {
    ".gnupg/gpg-agent.conf".text = with pkgs; ''
      pinentry-program ${pinentry_mac}/${pinentry_mac.binaryPath}
    '';
    ".config/ideavim/ideavimrc".text = builtins.readFile ../../share/ideavimrc.vim;
  };
}
