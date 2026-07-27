#!/usr/bin/env bash

export HISTFILE="${HISTFILE:-$HOME/.bash_history}"
export HISTSIZE="${HISTSIZE:-50000}"
export HISTFILESIZE="${HISTFILESIZE:-50000}"
export HISTCONTROL="${HISTCONTROL:-ignoreboth:erasedups}"
export HISTIGNORE="${HISTIGNORE:-ls:ll:la:l:pwd:clear:history:exit}"

shopt -s histappend
shopt -s cmdhist
shopt -s lithist

__profile_history_sync() {
    history -a
    history -n
}
