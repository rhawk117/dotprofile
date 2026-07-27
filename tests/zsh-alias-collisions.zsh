#!/usr/bin/env zsh
set -eu

ROOT_DIR="${0:A:h:h}"
export SHELL_CONFIG_HOME="$ROOT_DIR"
export HOME="$(mktemp -d)"
trap 'rm -rf "$HOME"' EXIT

# Clean shells do not guarantee cosmetic variables. Keep nounset enabled so
# optional environment assumptions fail loudly in tests.
unset LS_COLORS XDG_CACHE_HOME XDG_STATE_HOME FZF_DEFAULT_OPTS 2>/dev/null || true

# Dotprofile is loaded after Oh My Zsh in the supported WSL setup. It must not
# initialize completion again or replace OMZ's history configuration.
HISTFILE="$HOME/omz-history"
HISTSIZE=1234
SAVEHIST=567
compinit() {
    print -u2 -- 'dotprofile called compinit after Oh My Zsh'
    return 99
}

# Reproduce aliases that already exist before the profile is sourced.
alias reload='source ~/.zshrc'
alias copy='clip.exe'
alias paste='cat /dev/clipboard'
alias tree='ls -R'
alias cat='batcat'
alias fzhelp='printf stale'
alias profile-help='printf stale'
alias p10k-help='printf stale'

source "$ROOT_DIR/profiles/wsl-zsh/profile.zsh"

[[ "$HISTFILE" == "$HOME/omz-history" ]] || {
    print -u2 -- 'dotprofile replaced HISTFILE'
    exit 1
}
[[ "$HISTSIZE" == 1234 ]] || {
    print -u2 -- 'dotprofile replaced HISTSIZE'
    exit 1
}
[[ "$SAVEHIST" == 567 ]] || {
    print -u2 -- 'dotprofile replaced SAVEHIST'
    exit 1
}

for command_name in \
    reload copy paste tree cat \
    profile-help p10k-help fzhelp \
    gitsnap bkmark fzcd fzgrep; do
    whence -w "$command_name" | grep -q ': function$' || {
        print -u2 -- "expected function after profile load: $command_name"
        exit 1
    }
done

profile-help >/dev/null
p10k-help >/dev/null
fzhelp >/dev/null

print '[ok] Zsh profile integration passed'
