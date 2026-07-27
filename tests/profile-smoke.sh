#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
MODE="${1:-all}"

fail() {
    printf '[fail] %s\n' "$*" >&2
    exit 1
}

check_function() {
    type "$1" >/dev/null 2>&1 || fail "missing function: $1"
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

check_zsh_syntax() {
    local file

    command -v zsh >/dev/null 2>&1 || fail 'zsh is required for the WSL profile test'

    while IFS= read -r file; do
        zsh -n "$file"
    done < <(find "$ROOT_DIR" -type f -name '*.zsh' -not -path '*/.git/*' -print)

    # Common files must parse when sourced by Zsh too.
    zsh -n "$ROOT_DIR/profiles/common/profile.sh"
    zsh -n "$ROOT_DIR/profiles/common/functions.sh"
    zsh -n "$ROOT_DIR/profiles/common/daily-tools.sh"
    zsh -n "$ROOT_DIR/profiles/common/fzf-tools.sh"
    zsh -n "$ROOT_DIR/profiles/common/help.sh"
}

run_common_runtime_test() {
    local sandbox
    sandbox="$(mktemp -d)"
    trap 'rm -rf "$sandbox"' RETURN

    HOME="$sandbox/home"
    mkdir -p "$HOME"
    export HOME
    export SHELL_CONFIG_HOME="$ROOT_DIR"
    export BAT_BIN="command-that-does-not-exist"
    export FD_BIN="command-that-does-not-exist"
    export NO_COLOR=1

    # shellcheck disable=SC1091
    source "$ROOT_DIR/profiles/common/profile.sh"

    local function_name
    for function_name in \
        profile-help gitsnap gitfeat bkmark upby rglob gr gri \
        fzhelp fzls fzinfo fzcd fznano fzvs fzless fzmore \
        fzclip fzh fzgc fzgrep fzg fzdiff fzcomp fzps; do
        check_function "$function_name"
    done

    profile-help >/dev/null
    fzhelp >/dev/null
    fzhelp fzmore >/dev/null
    gitsnap --help >/dev/null
    gitfeat --help >/dev/null
    bkmark --help >/dev/null

    mkdir -p "$sandbox/search/.git" "$sandbox/search/node_modules" "$sandbox/search/src"
    touch "$sandbox/search/.git/hidden" "$sandbox/search/node_modules/hidden" "$sandbox/search/src/visible"

    local results
    results="$(__fz_find "$sandbox/search" -type f)"
    grep -q 'src/visible' <<< "$results" || fail '__fz_find omitted a normal file'
    ! grep -q '/.git/' <<< "$results" || fail '__fz_find entered .git'
    ! grep -q '/node_modules/' <<< "$results" || fail '__fz_find entered node_modules'

    mkdir -p "$sandbox/bookmark/child"
    cd "$sandbox/bookmark"
    bkmark >/dev/null
    cd child
    bkmark go >/dev/null
    [[ "$PWD" == "$sandbox/bookmark" ]] || fail 'bkmark did not restore the saved directory'

    mkdir -p "$sandbox/repo"
    cd "$sandbox/repo"
    git init -q
    git config user.name 'Dotprofile Test'
    git config user.email 'dotprofile@example.invalid'
    printf 'first\n' > tracked.txt
    gitsnap -m 'initial snapshot' --add tracked.txt >/dev/null
    [[ "$(git log -1 --format=%s)" == 'initial snapshot' ]] || fail 'gitsnap did not create the expected commit'

    printf 'second\n' >> tracked.txt
    gitsnap -m 'second snapshot' >/dev/null
    [[ "$(git log -1 --format=%s)" == 'second snapshot' ]] || fail 'gitsnap default staging failed'
}

run_installer_test() {
    local profile="$1"
    local sandbox shell_command rc_file
    sandbox="$(mktemp -d)"
    trap 'rm -rf "$sandbox"' RETURN

    HOME="$sandbox/home"
    mkdir -p "$HOME"
    export HOME NO_COLOR=1

    bash "$ROOT_DIR/install.sh" --profile "$profile" --target "$HOME/.configs" >/dev/null
    bash "$ROOT_DIR/install.sh" --profile "$profile" --target "$HOME/.configs" >/dev/null

    if [[ "$profile" == 'git-bash' ]]; then
        rc_file="$HOME/.bashrc"
        [[ "$(grep -c '^# >>> portable-shell-profiles >>>$' "$rc_file")" -eq 1 ]] ||
            fail 'Git Bash installer duplicated its managed block'

        shell_command='source "$HOME/.bashrc"; type profile-help fzhelp gitsnap bkmark >/dev/null; profile-help >/dev/null; fzhelp >/dev/null'
        HOME="$HOME" MSYSTEM=MINGW64 bash --noprofile --norc -ic "$shell_command" >/dev/null 2>&1
    else
        rc_file="$HOME/.zshrc"
        [[ "$(grep -c '^# >>> portable-shell-profiles >>>$' "$rc_file")" -eq 1 ]] ||
            fail 'WSL Zsh installer duplicated its managed block'

        HOME="$HOME" zsh -dfc \
            'source "$HOME/.zshrc"; type profile-help p10k-help fzhelp gitsnap bkmark >/dev/null; profile-help >/dev/null; p10k-help >/dev/null; fzhelp >/dev/null'
    fi
}

check_bash_syntax

case "$MODE" in
    all)
        check_zsh_syntax
        run_common_runtime_test
        run_installer_test git-bash
        run_installer_test wsl-zsh
        ;;
    git-bash)
        run_common_runtime_test
        run_installer_test git-bash
        ;;
    wsl-zsh)
        check_zsh_syntax
        run_common_runtime_test
        run_installer_test wsl-zsh
        ;;
    *)
        fail "unknown test mode: $MODE"
        ;;
esac

printf '[ok] profile smoke tests passed (%s)\n' "$MODE"
