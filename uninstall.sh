#!/usr/bin/env bash
set -Eeuo pipefail

TARGET="${HOME}/.configs"
PURGE=0

while (($#)); do
    case "$1" in
    --target)
        TARGET="$2"
        shift 2
        ;;
    --purge)
        PURGE=1
        shift
        ;;
    -h | --help)
        printf 'Usage: bash uninstall.sh [--target PATH] [--purge]\n'
        exit 0
        ;;
    *)
        printf 'Unknown option: %s\n' "$1" >&2
        exit 1
        ;;
    esac
done

strip_block() {
    local file="$1"
    local start="$2"
    local end="$3"
    local tmp

    [[ -f "$file" ]] || return 0
    tmp="$(mktemp)"
    awk -v start="$start" -v end="$end" '
        $0 == start { skipping = 1; next }
        $0 == end   { skipping = 0; next }
        !skipping   { print }
    ' "$file" >"$tmp"
    cat "$tmp" >"$file"
    rm -f "$tmp"
}

for file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.nanorc" \
    "$HOME/.gitconfig" "$HOME/.inputrc"; do
    strip_block "$file" \
        "# >>> portable-shell-profiles >>>" \
        "# <<< portable-shell-profiles <<<"
done

strip_block "$HOME/.bash_profile" \
    "# >>> portable-shell-profiles bashrc >>>" \
    "# <<< portable-shell-profiles bashrc <<<"

if ((PURGE)); then
    rm -rf \
        "$TARGET/profiles" \
        "$TARGET/nano" \
        "$TARGET/git" \
        "$TARGET/ripgrep" \
        "$TARGET/bin" \
        "$TARGET/README.md" \
        "$TARGET/VERSION" \
        "$TARGET/uninstall.sh"
    printf 'Removed managed files from %s\n' "$TARGET"
else
    printf 'Removed startup-file include blocks; retained %s\n' "$TARGET"
fi
