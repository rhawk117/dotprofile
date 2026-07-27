#!/usr/bin/env zsh

autoload -Uz compinit

_completion_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_completion_dump="$_completion_cache_dir/zcompdump"
_fzf_init_file="$_completion_cache_dir/fzf-init.zsh"
mkdir -p "$_completion_cache_dir"

# A normal compinit performs a full security audit and completion scan. Reuse
# yesterday's dump with -C and rebuild it only when absent or stale.
if [[ ! -s "$_completion_dump" || -n "$_completion_dump"(#qN.mh+24) ]]; then
    compinit -d "$_completion_dump"
else
    compinit -C -d "$_completion_dump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$_completion_cache_dir"

# Generating fzf's shell integration starts an external process. Cache the
# generated script and refresh it only when the fzf executable is newer.
if command -v fzf >/dev/null 2>&1; then
    _fzf_bin="$(command -v fzf)"
    if [[ ! -s "$_fzf_init_file" || "$_fzf_bin" -nt "$_fzf_init_file" ]]; then
        fzf --zsh >| "$_fzf_init_file" 2>/dev/null || :
    fi
    [[ -s "$_fzf_init_file" ]] && source "$_fzf_init_file"
fi

# Give common aliases the completion of their underlying command.
compdef _git gs gstatus gaa gap gc gsw grs grst glog gloga \
    gpull gpush gcommit gdiff gds gbranch gfetch gamend 2>/dev/null
compdef _kubectl k kgp kga kgs kgd kctx kctxs kns 2>/dev/null
compdef _docker d dps dpa di dcu dcud dcd dcl dcb 2>/dev/null

unset _completion_cache_dir _completion_dump _fzf_init_file _fzf_bin
