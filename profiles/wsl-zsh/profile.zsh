#!/usr/bin/env zsh

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

# Zsh expands aliases while parsing function definitions. Clear every command
# defined by the platform module before loading it.
unalias \
    copy paste openwin winpath unixpath winhome ports port \
    p10k-save p10k-use p10k-list p10k-edit p10k-new p10k-help \
    2>/dev/null || true

for __dotprofile_wsl_path in \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/environment.zsh" \
    "$SHELL_CONFIG_HOME/profiles/common/profile.sh" \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/paths.zsh" \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/options.zsh" \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/bindings.zsh" \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/completion.zsh" \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/functions.zsh" \
    "$SHELL_CONFIG_HOME/profiles/wsl-zsh/aliases.zsh"; do
    if [[ ! -r "$__dotprofile_wsl_path" ]]; then
        print -u2 -- "[dotprofile] required module is missing or unreadable: $__dotprofile_wsl_path"
        unset __dotprofile_wsl_path
        return 1
    fi

    if ! source "$__dotprofile_wsl_path"; then
        print -u2 -- "[dotprofile] failed to source module: $__dotprofile_wsl_path"
        unset __dotprofile_wsl_path
        return 1
    fi
done

unset __dotprofile_wsl_path

# Oh My Zsh owns completion, history, and Powerlevel10k initialization.
