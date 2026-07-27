#!/usr/bin/env bash

shell_rc_file() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        printf '%s\n' "${ZDOTDIR:-$HOME}/.zshrc"
    else
        printf '%s\n' "$HOME/.bashrc"
    fi
}

reload() {
    local rc
    rc="$(shell_rc_file)"
    # shellcheck disable=SC1090
    source "$rc"
}

catrc() {
    command cat "$(shell_rc_file)"
}

editrc() {
    "${EDITOR:-nano}" "$(shell_rc_file)"
}

mkcd() {
    [[ $# -eq 1 ]] || {
        printf 'usage: mkcd DIRECTORY\n' >&2
        return 2
    }
    mkdir -p -- "$1" && cd -- "$1"
}

croot() {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        printf 'not inside a Git repository\n' >&2
        return 1
    }
    cd -- "$root"
}

pathlines() {
    printf '%s\n' "$PATH" | tr ':' '\n'
}

extract() {
    [[ $# -eq 1 ]] || {
        printf 'usage: extract ARCHIVE\n' >&2
        return 2
    }
    [[ -f "$1" ]] || {
        printf 'not a file: %s\n' "$1" >&2
        return 1
    }

    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz|*.txz)   tar xJf "$1" ;;
        *.tar.zst|*.tzst) tar --zstd -xf "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.xz)             unxz "$1" ;;
        *.zip)            unzip "$1" ;;
        *.7z)             7z x "$1" ;;
        *.rar)            unrar x "$1" ;;
        *)
            printf 'unsupported archive: %s\n' "$1" >&2
            return 1
            ;;
    esac
}

psg() {
    [[ $# -ge 1 ]] || {
        printf 'usage: psg PATTERN\n' >&2
        return 2
    }
    ps aux | grep --color=auto -i -- "$*" | grep -v '[g]rep'
}

lstree() {
    command ls \
        -lahR \
        --group-directories-first \
        --time-style=long-iso \
        --color=auto \
        "${@:-.}"
}

tree() {
    if command -v tree >/dev/null 2>&1; then
        command tree -a -C --dirsfirst "$@"
    else
        lstree "${@:-.}"
    fi
}

cat() {
    local bin="${BAT_BIN:-bat}"
    if command -v "$bin" >/dev/null 2>&1; then
        "$bin" --paging=never "$@"
    else
        command cat "$@"
    fi
}

rawcat() {
    command cat "$@"
}

ccat() {
    "${BAT_BIN:-bat}" --style=plain --paging=never "$@"
}

b() {
    "${BAT_BIN:-bat}" "$@"
}

bn() {
    "${BAT_BIN:-bat}" --paging=never "$@"
}

bl() {
    "${BAT_BIN:-bat}" --paging=always "$@"
}

fcd() {
    local selected
    selected="$("${FD_BIN:-fd}" \
        --type d \
        --hidden \
        --follow \
        --exclude .git |
        fzf --prompt='cd> ')" || return
    [[ -n "$selected" ]] && cd -- "$selected"
}

fe() {
    local selected
    selected="$("${FD_BIN:-fd}" \
        --type f \
        --hidden \
        --follow \
        --exclude .git |
        fzf \
            --prompt='edit> ' \
            --preview "${BAT_BIN:-bat} --color=always --style=numbers --line-range=:300 {}")" ||
        return

    [[ -n "$selected" ]] && "${EDITOR:-nano}" "$selected"
}

fif() {
    [[ $# -ge 1 ]] || {
        printf 'usage: fif SEARCH_PATTERN\n' >&2
        return 2
    }

    local selected file line
    selected="$(
        rg \
            --line-number \
            --no-heading \
            --color=always \
            --smart-case \
            -- "$*" |
        fzf \
            --ansi \
            --delimiter=: \
            --prompt='match> ' \
            --preview "${BAT_BIN:-bat} --color=always --style=numbers --highlight-line {2} {1}"
    )" || return

    file="${selected%%:*}"
    line="${selected#*:}"
    line="${line%%:*}"

    "${EDITOR:-nano}" "+$line" "$file"
}

serve() {
    python3 -m http.server "${1:-8000}"
}

json() {
    python3 -m json.tool "$@"
}

jwt_payload() {
    [[ $# -eq 1 ]] || {
        printf 'usage: jwt_payload TOKEN\n' >&2
        return 2
    }

    python3 - "$1" <<'PY'
import base64
import json
import sys

parts = sys.argv[1].split(".")
if len(parts) < 2:
    raise SystemExit("not a JWT-like token")

payload = parts[1] + "=" * (-len(parts[1]) % 4)
decoded = base64.urlsafe_b64decode(payload)
print(json.dumps(json.loads(decoded), indent=2, sort_keys=True))
PY
}
