#!/usr/bin/env bash
# Variables that behave consistently in WSL Zsh and Git Bash.

export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-$EDITOR}"
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"

export PAGER="${PAGER:-less}"
export LESS="${LESS:--RFXi}"
export GIT_PAGER="${GIT_PAGER:-less -R}"
export MANPAGER="${MANPAGER:-less -R}"
export SYSTEMD_PAGER="${SYSTEMD_PAGER:-less -R}"

export CLICOLOR="${CLICOLOR:-1}"
export CLICOLOR_FORCE="${CLICOLOR_FORCE:-0}"
export GREP_COLORS="${GREP_COLORS:-ms=01;33:mc=01;33:sl=:cx=:fn=35:ln=32:bn=32:se=36}"

export PYTHONDONTWRITEBYTECODE="${PYTHONDONTWRITEBYTECODE:-1}"
export PIP_DISABLE_PIP_VERSION_CHECK="${PIP_DISABLE_PIP_VERSION_CHECK:-1}"

if [[ -f "$HOME/.pythonrc.py" ]]; then
    export PYTHONSTARTUP="${PYTHONSTARTUP:-$HOME/.pythonrc.py}"
fi

export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-$SHELL_CONFIG_HOME/ripgrep/config}"
export BAT_THEME="${BAT_THEME:-ansi}"

# TERM is intentionally not overridden. The terminal emulator owns it.
