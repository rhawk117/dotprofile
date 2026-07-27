#!/usr/bin/env zsh

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/environment.zsh"
source "$SHELL_CONFIG_HOME/profiles/common/profile.sh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/paths.zsh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/options.zsh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/history.zsh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/bindings.zsh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/completion.zsh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/functions.zsh"
source "$SHELL_CONFIG_HOME/profiles/wsl-zsh/aliases.zsh"

# Powerlevel10k remains owned by the user's existing .zshrc.
