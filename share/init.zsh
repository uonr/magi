zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # https://superuser.com/a/109232
autoload -U promptinit; promptinit
prompt pure
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
