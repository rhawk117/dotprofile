#!/usr/bin/env zsh

export BAT_BIN="${BAT_BIN:-batcat}"
export FD_BIN="${FD_BIN:-fdfind}"
export BROWSER="${BROWSER:-explorer.exe}"

export FZF_DEFAULT_COMMAND="$FD_BIN --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FD_BIN --type d --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=40% --layout=reverse --border --info=inline}"
