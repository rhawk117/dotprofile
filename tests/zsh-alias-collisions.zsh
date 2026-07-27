#!/usr/bin/env zsh
set -eu

ROOT_DIR="${0:A:h:h}"
export SHELL_CONFIG_HOME="$ROOT_DIR"
export HOME="$(mktemp -d)"
trap 'rm -rf "$HOME"' EXIT

# Clean shells do not guarantee cosmetic variables such as LS_COLORS. Keep
# nounset enabled so optional environment assumptions fail loudly in tests.
unset LS_COLORS XDG_CACHE_HOME XDG_STATE_HOME FZF_DEFAULT_OPTS 2>/dev/null || true

# Reproduce the real failure mode: aliases already exist before the profile is
# sourced, so Zsh would otherwise expand them while parsing function bodies.
alias reload='source ~/.zshrc'
alias copy='clip.exe'
alias paste='cat /dev/clipboard'
alias tree='ls -R'
alias cat='batcat'
alias fzhelp='printf stale'
alias profile-help='printf stale'
alias p10k-help='printf stale'

source "$ROOT_DIR/profiles/wsl-zsh/profile.zsh"

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

print '[ok] Zsh alias-collision profile load passed'
