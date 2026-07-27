#!/usr/bin/env bash

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

source "$SHELL_CONFIG_HOME/profiles/git-bash/environment.bash"
source "$SHELL_CONFIG_HOME/profiles/common/profile.sh"
source "$SHELL_CONFIG_HOME/profiles/git-bash/paths.bash"
source "$SHELL_CONFIG_HOME/profiles/git-bash/history.bash"
source "$SHELL_CONFIG_HOME/profiles/git-bash/bindings.bash"
source "$SHELL_CONFIG_HOME/profiles/git-bash/completion.bash"
source "$SHELL_CONFIG_HOME/profiles/git-bash/functions.bash"
source "$SHELL_CONFIG_HOME/profiles/git-bash/aliases.bash"
source "$SHELL_CONFIG_HOME/profiles/git-bash/prompt.bash"
