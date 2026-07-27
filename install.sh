#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

VERSION="1.0.0"
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET="${HOME}/.configs"
PROFILE="auto"
DRY_RUN=0
PATCH_RC=1

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_BLUE=$'\033[34m'
    C_CYAN=$'\033[36m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
else
    C_RESET=""
    C_BOLD=""
    C_BLUE=""
    C_CYAN=""
    C_GREEN=""
    C_YELLOW=""
    C_RED=""
fi

info() { printf '%s==>%s %s\n' "$C_BLUE$C_BOLD" "$C_RESET" "$*"; }
success() { printf '%s[ok]%s %s\n' "$C_GREEN$C_BOLD" "$C_RESET" "$*"; }
warn() { printf '%s[!!]%s %s\n' "$C_YELLOW$C_BOLD" "$C_RESET" "$*" >&2; }
die() {
    printf '%s[error]%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$*" >&2
    exit 1
}
detail() { printf '    %s%s%s\n' "$C_CYAN" "$*" "$C_RESET"; }

usage() {
    cat <<'EOF'
Usage: bash install.sh [options]

Options:
  --profile auto|wsl-zsh|git-bash
  --target PATH
  --dry-run
  --no-rc
  -h, --help
EOF
}

while (($#)); do
    case "$1" in
    --profile)
        [[ $# -ge 2 ]] || die "--profile requires a value"
        PROFILE="$2"
        shift 2
        ;;
    --target)
        [[ $# -ge 2 ]] || die "--target requires a path"
        TARGET="$2"
        shift 2
        ;;
    --dry-run)
        DRY_RUN=1
        shift
        ;;
    --no-rc)
        PATCH_RC=0
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        die "Unknown option: $1"
        ;;
    esac
done

detect_profile() {
    if [[ "$PROFILE" != "auto" ]]; then
        printf '%s\n' "$PROFILE"
        return
    fi

    if [[ "${MSYSTEM:-}" == MINGW* || "${MSYSTEM:-}" == MSYS* ]]; then
        printf '%s\n' "git-bash"
    elif grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null ||
        grep -qi microsoft /proc/version 2>/dev/null; then
        printf '%s\n' "wsl-zsh"
    else
        die "Could not detect WSL or Git Bash; pass --profile explicitly"
    fi
}

PROFILE="$(detect_profile)"
case "$PROFILE" in
wsl-zsh | git-bash) ;;
*) die "Unsupported profile: $PROFILE" ;;
esac

TARGET="$(cd "$(dirname "$TARGET")" 2>/dev/null && pwd -P)/$(basename "$TARGET")"
STAMP="$(date +'%Y%m%d-%H%M%S')"
BACKUP_DIR="$TARGET/.backups/$STAMP"

run() {
    if ((DRY_RUN)); then
        printf '%s[dry]%s' "$C_CYAN" "$C_RESET"
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

backup_path() {
    local path="$1"
    local label="$2"

    [[ -e "$path" || -L "$path" ]] || return 0
    info "Backing up $label"
    run mkdir -p "$BACKUP_DIR/$label"
    run cp -a "$path" "$BACKUP_DIR/$label/"
}

strip_block_to_stdout() {
    local file="$1"
    local start="$2"
    local end="$3"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    awk -v start="$start" -v end="$end" '
        $0 == start { skipping = 1; next }
        $0 == end   { skipping = 0; next }
        !skipping   { print }
    ' "$file"
}

upsert_block() {
    local file="$1"
    local start="$2"
    local end="$3"
    local content="$4"
    local label="$5"
    local tmp

    backup_path "$file" "home-files"
    info "Updating $label"

    if ((DRY_RUN)); then
        detail "$file"
        return
    fi

    mkdir -p "$(dirname "$file")"
    touch "$file"
    tmp="$(mktemp)"
    strip_block_to_stdout "$file" "$start" "$end" >"$tmp"

    {
        cat "$tmp"
        [[ ! -s "$tmp" ]] || printf '\n'
        printf '%s\n' "$start"
        printf '%s\n' "$content"
        printf '%s\n' "$end"
    } >"$file"

    rm -f "$tmp"
}

copy_managed_tree() {
    local name="$1"
    local source="$ROOT_DIR/$name"
    local destination="$TARGET/$name"

    [[ -e "$source" ]] || die "Bundle is missing: $source"
    backup_path "$destination" "managed"
    info "Installing $name"
    run rm -rf "$destination"
    run mkdir -p "$(dirname "$destination")"
    run cp -a "$source" "$destination"
}

command_status() {
    local label="$1"
    shift
    local candidate

    for candidate in "$@"; do
        if command -v "$candidate" >/dev/null 2>&1; then
            success "$label: $candidate"
            return 0
        fi
    done

    warn "$label not found (${*})"
    return 1
}

printf '\n%sPortable shell profiles %s%s\n' "$C_BOLD" "$VERSION" "$C_RESET"
printf '%s\n\n' "${C_BLUE}────────────────────────────────────────${C_RESET}"
detail "Profile: $PROFILE"
detail "Target:  $TARGET"
((DRY_RUN)) && detail "Mode:    dry run"

run mkdir -p "$TARGET"

for item in profiles nano git ripgrep bin; do
    copy_managed_tree "$item"
done

for item in README.md VERSION uninstall.sh; do
    backup_path "$TARGET/$item" "managed"
    info "Installing $item"
    run cp -a "$ROOT_DIR/$item" "$TARGET/$item"
done

run chmod +x "$TARGET/bin/profile-doctor" "$TARGET/uninstall.sh"

printf -v target_q '%q' "$TARGET"

if ((PATCH_RC)); then
    shell_block_start="# >>> shell-profile >>>"
    shell_block_end="# <<< shell-profile <<<"

    if [[ "$PROFILE" == "wsl-zsh" ]]; then
        shell_content="export SHELL_CONFIG_HOME=$target_q
source \"\$SHELL_CONFIG_HOME/profiles/wsl-zsh/profile.zsh\""
        upsert_block "$HOME/.zshrc" "$shell_block_start" "$shell_block_end" \
            "$shell_content" ".zshrc"
    else
        shell_content="export SHELL_CONFIG_HOME=$target_q
source \"\$SHELL_CONFIG_HOME/profiles/git-bash/profile.bash\""
        upsert_block "$HOME/.bashrc" "$shell_block_start" "$shell_block_end" \
            "$shell_content" ".bashrc"

        bash_profile="${HOME}/.bash_profile"
        if ! grep -Eq '(^|[[:space:]])(source|\.)[[:space:]].*\.bashrc' \
            "$bash_profile" 2>/dev/null; then
            upsert_block "$bash_profile" \
                "# >>> shell-profile bashrc >>>" \
                "# <<< shell-profile bashrc <<<" \
                '[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"' \
                ".bash_profile"
        else
            success ".bash_profile already loads .bashrc"
        fi

        inputrc_content="\$include $TARGET/profiles/git-bash/inputrc"
        upsert_block "$HOME/.inputrc" \
            "# >>> shell-profile >>>" \
            "# <<< shell-profile <<<" \
            "$inputrc_content" ".inputrc"
    fi

    nano_content="include \"$TARGET/nano/nanorc\""
    upsert_block "$HOME/.nanorc" \
        "# >>> shell-profile >>>" \
        "# <<< shell-profile <<<" \
        "$nano_content" ".nanorc"

    git_content="[include]
    path = $TARGET/git/common.gitconfig
[include]
    path = $TARGET/git/$PROFILE.gitconfig
[core]
    excludesFile = $TARGET/git/ignore"
    upsert_block "$HOME/.gitconfig" \
        "# >>> shell-profile >>>" \
        "# <<< shell-profile <<<" \
        "$git_content" ".gitconfig"
fi

printf '\n'
info "Dependency check"
missing=0
command_status "Git" git || missing=1
command_status "Nano" nano || missing=1
command_status "fzf" fzf || missing=1
command_status "ripgrep" rg || missing=1
command_status "less" less || missing=1

if [[ "$PROFILE" == "wsl-zsh" ]]; then
    command_status "fd" fdfind fd || missing=1
    command_status "bat" batcat bat || missing=1
    command_status "clipboard paste" win32yank.exe wl-paste xclip xsel || missing=1
else
    command_status "fd" fd || missing=1
    command_status "bat" bat || missing=1
    [[ -e /dev/clipboard ]] && success "clipboard: /dev/clipboard" ||
        warn "/dev/clipboard is unavailable in this Git Bash session"
fi

printf '\n'
if ((DRY_RUN)); then
    success "Dry run completed; nothing was changed"
else
    success "Installed into $TARGET"
    detail "Reload with: reload"
    detail "Check with:  profile-doctor"
    if ((missing)); then
        warn "Some optional or expected tools are missing; the profile remains usable"
    fi
fi
