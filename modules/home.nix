{ config, pkgs, lib, ... }:
with lib;
let 
  commonAliases = import ./aliases.nix;
in {
  options.home = {
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
  };
  config = let
    cfg = config.home;
    aliases = commonAliases // cfg.aliases;
  in {
    home.packages = with pkgs; [
    ];

    programs.fish.shellAliases = aliases;
    programs.zsh.shellAliases = aliases;
    programs.bash.shellAliases = aliases;

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
      ignores = [ ".DS_Store" ".idea/" ".vscode/" ];
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

  };
}
