{ pkgs, ... }:
let
  aliases = {
    l = "exa -s mod --git";
    ls = "exa -s mod --git";
    ll = "exa -lahg -s mod --git --time-style=long-iso";
    grep = "rg";
    sys = "systemctl";
    jou = "journalctl";
    jor = "journalctl";
  };
in
{
  programs.fish.shellAliases = aliases;
  programs.zsh.shellAliases = aliases;
  programs.bash.shellAliases = aliases;
}
