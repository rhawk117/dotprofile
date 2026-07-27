#!/usr/bin/env zsh

# Oh My Zsh already initializes Zsh's completion system. Dotprofile must not run
# compinit again or replace OMZ's completion styles; it only attaches existing
# completers to aliases defined by the shared profile.
if (( $+functions[compdef] )); then
    compdef _git gs gstatus gaa gap gc gsw grs grst glog gloga \
        gpull gpush gcommit gdiff gds gbranch gfetch gamend 2>/dev/null
    compdef _kubectl k kgp kga kgs kgd kctx kctxs kns 2>/dev/null
    compdef _docker d dps dpa di dcu dcud dcd dcl dcb 2>/dev/null
fi

# The daily fzf functions invoke fzf directly and need no shell integration.
# Opt in only when Ctrl+T, Ctrl+R, and Alt+C fzf widgets are explicitly wanted.
if [[ "${DOTPROFILE_ENABLE_FZF_WIDGETS:-0}" == 1 ]] && \
        command -v fzf >/dev/null 2>&1; then
    _dotprofile_fzf_init="$(fzf --zsh 2>/dev/null || true)"
    [[ -z "$_dotprofile_fzf_init" ]] || eval "$_dotprofile_fzf_init"
    unset _dotprofile_fzf_init
fi
