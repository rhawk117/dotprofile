#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

export HOME="$SANDBOX/home"
export NO_COLOR=1
mkdir -p "$HOME"

bash "$ROOT_DIR/install.sh" \
    --profile wsl-zsh \
    --target "$SANDBOX/configs" >/dev/null

NANORC="$HOME/.nanorc"

[[ -s "$NANORC" ]] || {
    printf '[fail] installer did not create %s\n' "$NANORC" >&2
    exit 1
}

grep -Fq '# >>> shell-profile >>>' "$NANORC"
grep -Fq 'set autoindent' "$NANORC"
grep -Fq 'bind ^A mark main' "$NANORC"

if grep -Eq '^[[:space:]]*include[[:space:]].*/nano/nanorc' "$NANORC"; then
    printf '[fail] generated nanorc still includes the settings file\n' >&2
    exit 1
fi

# Nano exits immediately after reading configuration when given --version. Any
# invalid top-level directives are printed to stderr and make this test fail.
nano --rcfile "$NANORC" --version >/dev/null

printf '[ok] generated Nano configuration is valid\n'
