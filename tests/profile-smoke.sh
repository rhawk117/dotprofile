#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
MODE="${1:-all}"

fail() {
    printf '[fail] %s\n' "$*" >&2
    exit 1
}

assert_function() {
    type "$1" 2>/dev/null | grep -q 'function' || fail "missing function: $1"
}

assert_loader_mentions_every_module() {
    local directory="$1"
    local loader="$2"
    local module_pattern="$3"
    local file name

    while IFS= read -r file; do
        name="$(basename "$file")"
        [[ "$file" == "$loader" ]] && continue
        grep -Fq "$name" "$loader" || fail "loader omits module: $file"
    done < <(find "$directory" -maxdepth 1 -type f -name "$module_pattern" | sort)
}

assert_installer_manages_file() {
    local file="$1"
    local relative_path

    relative_path="${file#"$ROOT_DIR"/}"
    grep -Fq "$relative_path" "$ROOT_DIR/install.sh" ||
        fail "installer omits non-shell profile file: $relative_path"
}

check_bash_syntax() {
    local file

    while IFS= read -r file; do
        bash -n "$file"
    done < <(
        find "$ROOT_DIR" -type f \
            \( -name '*.sh' -o -name '*.bash' -o -path '*/bin/profile-doctor' \) \
            -not -path '*/.git/*' \
            -print
    )
}

run_git_bash_load() {
    export SHELL_CONFIG_HOME="$ROOT_DIR"
    export HOME="$(mktemp -d)"
    export MSYSTEM=MINGW64
    trap 'rm -rf "$HOME"' RETURN

    # shellcheck disable=SC1091
    source "$ROOT_DIR/profiles/git-bash/profile.bash"

    for command_name in reload copy paste profile-help fzhelp gitsnap bkmark; do
        assert_function "$command_name"
    done
}

run_wsl_zsh_load() {
    command -v zsh >/dev/null 2>&1 || fail 'zsh is required'
    zsh "$ROOT_DIR/tests/zsh-alias-collisions.zsh"
}

check_bash_syntax
assert_loader_mentions_every_module \
    "$ROOT_DIR/profiles/common" \
    "$ROOT_DIR/profiles/common/profile.sh" \
    '*.sh'
assert_loader_mentions_every_module \
    "$ROOT_DIR/profiles/git-bash" \
    "$ROOT_DIR/profiles/git-bash/profile.bash" \
    '*.bash'
assert_loader_mentions_every_module \
    "$ROOT_DIR/profiles/wsl-zsh" \
    "$ROOT_DIR/profiles/wsl-zsh/profile.zsh" \
    '*.zsh'

# Readline consumes this through the installer-managed ~/.inputrc include. It is
# configuration data, not a shell module, and must never be sourced by Bash.
assert_installer_manages_file "$ROOT_DIR/profiles/git-bash/inputrc"

case "$MODE" in
    all)
        run_git_bash_load
        run_wsl_zsh_load
        ;;
    git-bash)
        run_git_bash_load
        ;;
    wsl-zsh)
        run_wsl_zsh_load
        ;;
    *)
        fail "unknown mode: $MODE"
        ;;
esac

printf '[ok] profile smoke tests passed (%s)\n' "$MODE"
