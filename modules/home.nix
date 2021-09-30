{ pkgs, ... }:
{
  imports = [
    ./aliases.nix
  ];
  home.packages = with pkgs; [
  ];
  programs.home-manager.enable = true;
  programs.bash = {
    enable = true;
    initExtra = ''
      ${builtins.readFile ../share/gpg-agent.sh}
      ${builtins.readFile ../share/init.sh}
    '';
  };
  programs.git = {
    enable = true;
    aliases = {
      co = "checkout";
      c = "commit -a -S";
      clone = "clone --recurse-submodules";
      sub = "submodule update --init --recursive";
    };
    delta.enable = true;
    extraConfig = {
      difftool.prompt = true;
      diff.tool = "nvimdiff";
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };
  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
  programs.zoxide = {
    enable = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    defaultKeymap = "emacs";
    initExtra = ''
      fpath+=${pkgs.pure-prompt}/share/zsh/site-functions
      ${builtins.readFile ../share/gpg-agent.sh}
      ${builtins.readFile ../share/init.zsh}
    '';
    plugins = [
    ];
  };
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ../share/init.fish;
  };
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    prefix = "`";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      cpu
      better-mouse-mode
      gruvbox
    ];
    extraConfig = ''
      set -g mouse on
    '';
  };
}
