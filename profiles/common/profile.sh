#!/usr/bin/env bash
# Shared interactive profile. Bash and Zsh both source this file.

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/environment.sh"
# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/paths.sh"
# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/functions.sh"
# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/daily-tools.sh"
# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/fzf-tools.sh"
# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/help.sh"
# shellcheck disable=SC1091
source "$SHELL_CONFIG_HOME/profiles/common/aliases.sh"

if [[ -t 0 ]]; then
    stty -ixon 2>/dev/null || true
fi
