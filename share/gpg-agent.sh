#!/bin/bash
GPG_TTY="$(tty)"
export GPG_TTY
if [ -x "$(command -v gpg-connect-agent)" ]; then
    gpg-connect-agent /bye
fi

if [ -d "/run/user/$UID/gnupg" ]; then
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
fi
if [[ -x "$(command -v /usr/local/MacGPG2/bin/gpgconf)" ]]; then
    SSH_AUTH_SOCK=$(/usr/local/MacGPG2/bin/gpgconf --list-dirs agent-ssh-socket)
    export SSH_AUTH_SOCK
    (/usr/local/MacGPG2/bin/gpgconf --launch gpg-agent &)
fi
