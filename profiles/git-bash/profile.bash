#!/usr/bin/env bash

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

unalias \
    copy paste openwin winpath unixpath winhome ports port \
    __git_branch set_gitbash_prompt __portable_profile_prompt_command \
    2>/dev/null || true

__profile_source_required() {
    local file="$1"

    if [[ ! -r "$file" ]]; then
        printf '[dotprofile] required module is missing or unreadable: %s\n' "$file" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    if ! source "$file"; then
        printf '[dotprofile] failed to source module: %s\n' "$file" >&2
        return 1
    fi
}

for __profile_module in \
    environment.bash \
    ../common/profile.sh \
    paths.bash \
    history.bash \
    bindings.bash \
    completion.bash \
    functions.bash \
    aliases.bash \
    prompt.bash; do
    __profile_source_required \
        "$SHELL_CONFIG_HOME/profiles/git-bash/$__profile_module" || return 1
done

unset __profile_module
unset -f __profile_source_required 2>/dev/null || true
