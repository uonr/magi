zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # https://superuser.com/a/109232
autoload -U promptinit; promptinit
prompt pure
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

## History command configuration
# source: https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
