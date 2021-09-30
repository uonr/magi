{ pkgs, ... }:
{
  imports = [
    ./neovim.nix
  ];
  environment.systemPackages = with pkgs; [
    wget
    git
    btop
    exa # https://the.exa.website/introduction
    bat
    xplr # https://arijitbasu.in/xplr/en/introduction.html
    ripgrep # https://github.com/BurntSushi/ripgrep
    tmux # https://tmuxcheatsheet.com
    direnv # https://github.com/direnv/direnv
    tealdeer # https://github.com/dbrgn/tealdeer
    fd # https://github.com/sharkdp/fd#how-to-use
    sd # https://github.com/chmln/sd#quick-guide
    du-dust # https://github.com/bootandy/dust#usage
    procs # https://github.com/dalance/procs#usage
    unar
    killall
    gnupg
    pinentry-curses
    deploy-rs.deploy-rs
  ];
  programs.fish.enable = true;
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
  };
  environment.variables.PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
}
