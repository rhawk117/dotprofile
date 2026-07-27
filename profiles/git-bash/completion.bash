#!/usr/bin/env bash

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

if command -v fzf >/dev/null 2>&1; then
    _fzf_init="$(fzf --bash 2>/dev/null || true)"
    [[ -z "$_fzf_init" ]] || eval "$_fzf_init"
    unset _fzf_init
fi

_completion_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash-completion"
mkdir -p "$_completion_cache_dir"

if command -v "${FD_BIN:-fd}" >/dev/null 2>&1; then
    _fd_completion="$_completion_cache_dir/fd.bash"
    if [[ ! -s "$_fd_completion" ]]; then
        "${FD_BIN:-fd}" --gen-completions bash >"$_fd_completion" 2>/dev/null || true
    fi
    [[ -s "$_fd_completion" ]] && source "$_fd_completion"
fi

unset _completion_cache_dir _fd_completion
