#!/usr/bin/env bash
# Shared interactive profile. Bash and Zsh both source this file.

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

# Zsh expands aliases while parsing function definitions. Remove every command
# defined by the shared modules before those modules are parsed.
unalias \
    shell_rc_file reload catrc editrc mkcd croot pathlines extract psg \
    lstree tree cat rawcat ccat b bn bl fcd fe fif serve json jwt_payload \
    rc_info rc_success rc_warn rc_error gitsnap gitfeat upby rglob gr gri \
    bkmark __fz_has __fz_require __fz_find __fz_preview __fz_files __fz_dirs \
    __fz_preview_command __fz_open_line __fzps_list fzls fzinfo fzcd fznano \
    fzvs fzless fzmore fzclip fzh fzgc fzgrep fzg fzdiff fzcomp fzps fzhelp \
    profile-help \
    2>/dev/null || true

for __dotprofile_common_path in \
    "$SHELL_CONFIG_HOME/profiles/common/environment.sh" \
    "$SHELL_CONFIG_HOME/profiles/common/paths.sh" \
    "$SHELL_CONFIG_HOME/profiles/common/functions.sh" \
    "$SHELL_CONFIG_HOME/profiles/common/daily-tools.sh" \
    "$SHELL_CONFIG_HOME/profiles/common/fzf-tools.sh" \
    "$SHELL_CONFIG_HOME/profiles/common/help.sh" \
    "$SHELL_CONFIG_HOME/profiles/common/aliases.sh"; do
    if [[ ! -r "$__dotprofile_common_path" ]]; then
        printf '[dotprofile] required module is missing or unreadable: %s\n' \
            "$__dotprofile_common_path" >&2
        unset __dotprofile_common_path
        return 1
    fi

    # shellcheck disable=SC1090
    if ! source "$__dotprofile_common_path"; then
        printf '[dotprofile] failed to source module: %s\n' \
            "$__dotprofile_common_path" >&2
        unset __dotprofile_common_path
        return 1
    fi
done

unset __dotprofile_common_path

if [[ -t 0 ]]; then
    stty -ixon 2>/dev/null || true
fi
