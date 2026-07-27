#!/usr/bin/env zsh

autoload -Uz compinit
_completion_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_completion_cache_dir"
compinit -d "$_completion_cache_dir/zcompdump"

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

if command -v fzf >/dev/null 2>&1; then
    _fzf_init="$(fzf --zsh 2>/dev/null || true)"
    [[ -z "$_fzf_init" ]] || eval "$_fzf_init"
    unset _fzf_init
fi

# Give common aliases the completion of their underlying command.
compdef _git gs gstatus gaa gap gc gsw grs grst glog gloga \
    gpull gpush gcommit gdiff gds gbranch gfetch gamend 2>/dev/null
compdef _kubectl k kgp kga kgs kgd kctx kctxs kns 2>/dev/null
compdef _docker d dps dpa di dcu dcud dcd dcl dcb 2>/dev/null

unset _completion_cache_dir
