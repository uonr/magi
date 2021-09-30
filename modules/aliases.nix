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
    htop = "btop";
    top = "btop";
    doco = "docker-compose";
    fixgpg = "killall --wait gpg-agent && gpg-connect-agent updatestartuptty /bye > /dev/null";
  };
in
{
  programs.fish.shellAliases = aliases;
  programs.zsh.shellAliases = aliases;
  programs.bash.shellAliases = aliases;
}
