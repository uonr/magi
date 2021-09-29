#!/bin/bash
if [ -x "$(command -v gpg-connect-agent)" ]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
fi

