#!/usr/bin/env bash
# Shared interactive profile. Bash and Zsh both source this file.

: "${SHELL_CONFIG_HOME:=$HOME/.configs}"
export SHELL_CONFIG_HOME

# Zsh expands aliases while parsing function definitions. Remove every command
# that this profile defines before sourcing the function modules, otherwise a
# pre-existing alias such as `reload` can make the entire profile fail to parse.
unalias \
    shell_rc_file reload catrc editrc mkcd croot pathlines extract psg \
    lstree tree cat rawcat ccat b bn bl fcd fe fif serve json jwt_payload \
    rc_info rc_success rc_warn rc_error gitsnap gitfeat upby rglob gr gri bkmark \
    __fz_has __fz_require __fz_find __fz_preview __fz_files __fz_dirs \
    __fz_preview_command __fz_open_line __fzps_list \
    fzls fzinfo fzcd fznano fzvs fzless fzmore fzclip fzh fzgc fzgrep fzg \
    fzdiff fzcomp fzps fzhelp profile-help \
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
    environment.sh \
    paths.sh \
    functions.sh \
    daily-tools.sh \
    fzf-tools.sh \
    help.sh \
    aliases.sh; do
    __profile_source_required \
        "$SHELL_CONFIG_HOME/profiles/common/$__profile_module" || return 1
done

unset __profile_module
unset -f __profile_source_required 2>/dev/null || true

if [[ -t 0 ]]; then
    stty -ixon 2>/dev/null || true
fi
