#!/usr/bin/env bash

copy() {
    command cat > /dev/clipboard
}

paste() {
    command cat /dev/clipboard
}

openwin() {
    local target="${1:-.}"
    if [[ "$target" == http://* || "$target" == https://* ]]; then
        explorer.exe "$target"
    else
        explorer.exe "$(cygpath -w "$target")"
    fi
}

winpath() {
    cygpath -w "${1:-.}"
}

unixpath() {
    cygpath -u "$1"
}

winhome() {
    local home_path
    home_path="$(cygpath -u "$USERPROFILE")" || return
    cd -- "$home_path"
}

ports() {
    netstat.exe -ano
}

port() {
    [[ $# -eq 1 ]] || {
        printf 'usage: port NUMBER\n' >&2
        return 2
    }
    netstat.exe -ano | grep --color=auto -E "[:.]$1[[:space:]]"
}
