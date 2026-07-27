#!/usr/bin/env bash

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

unalias \
    copy paste openwin winpath unixpath winhome ports port \
    __git_branch set_gitbash_prompt __portable_profile_prompt_command \
    2>/dev/null || true

for __dotprofile_git_bash_path in \
    "$SHELL_CONFIG_HOME/profiles/git-bash/environment.bash" \
    "$SHELL_CONFIG_HOME/profiles/common/profile.sh" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/paths.bash" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/history.bash" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/bindings.bash" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/completion.bash" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/functions.bash" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/aliases.bash" \
    "$SHELL_CONFIG_HOME/profiles/git-bash/prompt.bash"; do
    if [[ ! -r "$__dotprofile_git_bash_path" ]]; then
        printf '[dotprofile] required module is missing or unreadable: %s\n' \
            "$__dotprofile_git_bash_path" >&2
        unset __dotprofile_git_bash_path
        return 1
    fi

    # shellcheck disable=SC1090
    if ! source "$__dotprofile_git_bash_path"; then
        printf '[dotprofile] failed to source module: %s\n' \
            "$__dotprofile_git_bash_path" >&2
        unset __dotprofile_git_bash_path
        return 1
    fi
done

unset __dotprofile_git_bash_path
