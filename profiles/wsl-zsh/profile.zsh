#!/usr/bin/env zsh

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

# Zsh expands aliases while parsing function definitions. Remove aliases for
# every platform function before loading the module that defines them.
unalias \
    __profile_source_required copy paste openwin winpath unixpath winhome \
    ports port p10k-save p10k-use p10k-list p10k-edit p10k-new p10k-help \
    2>/dev/null || true

__profile_source_required() {
    local file="$1"

    if [[ ! -r "$file" ]]; then
        print -u2 -- "[dotprofile] required module is missing or unreadable: $file"
        return 1
    fi

    if ! source "$file"; then
        print -u2 -- "[dotprofile] failed to source module: $file"
        return 1
    fi
}

for __profile_module in \
    environment.zsh \
    ../common/profile.sh \
    paths.zsh \
    options.zsh \
    history.zsh \
    bindings.zsh \
    completion.zsh \
    functions.zsh \
    aliases.zsh; do
    __profile_source_required \
        "$SHELL_CONFIG_HOME/profiles/wsl-zsh/$__profile_module" || return 1
done

unset __profile_module
unfunction __profile_source_required 2>/dev/null || true

# Powerlevel10k remains owned by the user's existing .zshrc.
