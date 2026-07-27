#!/usr/bin/env zsh

copy() {
    if command -v clip.exe >/dev/null 2>&1; then
        clip.exe
    elif command -v wl-copy >/dev/null 2>&1; then
        wl-copy
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --input
    else
        printf 'no clipboard copy backend found\n' >&2
        return 127
    fi
}

paste() {
    if command -v win32yank.exe >/dev/null 2>&1; then
        win32yank.exe -o --lf
    elif command -v wl-paste >/dev/null 2>&1; then
        wl-paste --no-newline
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -o
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --output
    else
        printf 'install win32yank, wl-clipboard, xclip, or xsel for paste\n' >&2
        return 127
    fi
}

openwin() {
    local target="${1:-.}"
    if [[ "$target" == http://* || "$target" == https://* ]]; then
        explorer.exe "$target"
    else
        explorer.exe "$(wslpath -w "$target")"
    fi
}

winpath() {
    wslpath -w "${1:-.}"
}

unixpath() {
    wslpath -u "$1"
}

winhome() {
    local home_path
    home_path="$(wslpath -u "$USERPROFILE")" || return
    cd -- "$home_path"
}

ports() {
    ss -tulpn
}

port() {
    [[ $# -eq 1 ]] || {
        printf 'usage: port NUMBER\n' >&2
        return 2
    }
    ss -tulpn | grep --color=auto -E "[:.]$1[[:space:]]"
}

P10K_THEME_DIR="${P10K_THEME_DIR:-$HOME/.configs/powerlevel10k/themes}"

p10k-save() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        print -u2 "usage: p10k-save THEME_NAME"
        return 2
    fi

    if [[ ! -f "$HOME/.p10k.zsh" ]]; then
        print -u2 "~/.p10k.zsh does not exist"
        return 1
    fi

    mkdir -p "$P10K_THEME_DIR"
    cp -- "$HOME/.p10k.zsh" "$P10K_THEME_DIR/$name.zsh"

    print "Saved Powerlevel10k theme: $name"
}

p10k-use() {
    local name="${1:-}"
    local config

    if [[ -z "$name" ]]; then
        print -u2 "usage: p10k-use THEME_NAME"
        return 2
    fi

    config="$P10K_THEME_DIR/$name.zsh"

    if [[ ! -f "$config" ]]; then
        print -u2 "Unknown Powerlevel10k theme: $name"
        return 1
    fi

    cp -- "$config" "$HOME/.p10k.zsh"

    # Replace the current shell instead of stacking another Zsh process.
    exec zsh
}

p10k-list() {
    local theme

    if [[ ! -d "$P10K_THEME_DIR" ]]; then
        print "No saved Powerlevel10k themes."
        return
    fi

    for theme in "$P10K_THEME_DIR"/*.zsh(N); do
        print "${theme:t:r}"
    done
}

p10k-edit() {
    local name="${1:-}"

    if [[ -n "$name" ]]; then
        "${EDITOR:-nano}" "$P10K_THEME_DIR/$name.zsh"
    else
        "${EDITOR:-nano}" "$HOME/.p10k.zsh"
    fi
}

p10k-new() {
    local backup

    mkdir -p "$P10K_THEME_DIR"

    if [[ -f "$HOME/.p10k.zsh" ]]; then
        backup="$P10K_THEME_DIR/backup-$(date +%Y%m%d-%H%M%S).zsh"
        cp -- "$HOME/.p10k.zsh" "$backup"
        print "Backed up current configuration to:"
        print "  $backup"
    fi

    p10k configure
}