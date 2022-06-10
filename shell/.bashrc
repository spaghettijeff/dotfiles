# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

echo 'find courses for next term'

force_color_prompt=yes
export PS1="[\u@\h \W]\[$(tput sgr0)\]\[\033[38;5;2m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
#PS1='[\u@\h \W]\]$ '

PATH=$PATH:/home/jeff/.scripts:/home/jeff/.local/bin

# Bash auto-completion
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion


#default config folder (~/.config)
export XDG_CONFIG_HOME=$HOME/.config
export WEECHAT_HOME="$XDG_CONFIG_HOME"/weechat


export EDITOR=nvim
export BROWSER=qutebrowser

if [ -t 0 ]; then
    export GPG_TTY="$(tty)"
    export PINENTRY_USER_DATA=USE_TTY=1
fi


#nnn filemanager config
export NNN_USE_EDITOR=1

n ()
{
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    fi
}


if [[ -f /home/jeff/.bash_aliases ]]; then
	. /home/jeff/.bash_aliases
fi
. "/home/jeff/.local/cargo/env"
