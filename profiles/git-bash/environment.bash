#!/usr/bin/env bash

export BAT_BIN="${BAT_BIN:-bat}"
export FD_BIN="${FD_BIN:-fd}"
export BROWSER="${BROWSER:-explorer.exe}"

export FZF_DEFAULT_COMMAND="$FD_BIN --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FD_BIN --type d --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=40% --layout=reverse --border --info=inline}"

export LESSCHARSET="${LESSCHARSET:-utf-8}"
