#!/usr/bin/env bash
set -u

PROFILE="auto"

usage() {
    cat <<'EOF'
Usage: bash prereqs.sh [--profile PROFILE]

Report required dotprofile prerequisites without installing or modifying anything.

Profiles:
  auto         Detect WSL, Linux, or Git Bash
  wsl-zsh      WSL with Zsh, Oh My Zsh, and Powerlevel10k
  linux-zsh    Linux with Zsh, Oh My Zsh, and Powerlevel10k
  git-bash     Git Bash on Windows

The script always prints copyable install commands for anything missing and exits
successfully unless its arguments are invalid.
EOF
}

while (($#)); do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || {
                printf 'missing value for --profile\n' >&2
                exit 2
            }
            PROFILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

case "$PROFILE" in
    auto|wsl-zsh|linux-zsh|git-bash) ;;
    *)
        printf 'unknown profile: %s\n' "$PROFILE" >&2
        exit 2
        ;;
esac

if [[ "$PROFILE" == auto ]]; then
    case "${MSYSTEM:-}" in
        MINGW*|MSYS*) PROFILE="git-bash" ;;
        *)
            if [[ -n "${WSL_DISTRO_NAME:-}" ]] ||
                    grep -qi microsoft /proc/version 2>/dev/null; then
                PROFILE="wsl-zsh"
            else
                PROFILE="linux-zsh"
            fi
            ;;
    esac
fi

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    C_BOLD=$'\033[1m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_CYAN=$'\033[36m'
    C_RESET=$'\033[0m'
else
    C_BOLD=""
    C_GREEN=""
    C_YELLOW=""
    C_CYAN=""
    C_RESET=""
fi

section() {
    printf '\n%s%s%s\n' "$C_BOLD" "$1" "$C_RESET"
}

present() {
    printf '  %s[ok]%s      %-20s %s\n' "$C_GREEN" "$C_RESET" "$1" "$2"
}

missing() {
    printf '  %s[missing]%s %-20s %s\n' "$C_YELLOW" "$C_RESET" "$1" "$2"
}

append_unique() {
    local value="$1"
    local existing

    for existing in "${INSTALL_ITEMS[@]:-}"; do
        [[ "$existing" == "$value" ]] && return
    done
    INSTALL_ITEMS+=("$value")
}

first_command() {
    local candidate

    for candidate in "$@"; do
        if command -v "$candidate" >/dev/null 2>&1; then
            command -v "$candidate"
            return 0
        fi
    done

    return 1
}

check_linux_requirement() {
    local label="$1"
    local package_key="$2"
    shift 2
    local path

    if path="$(first_command "$@")"; then
        present "$label" "$path"
    else
        missing "$label" "expected: $*"
        append_unique "$package_key"
    fi
}

linux_package_name() {
    local manager="$1"
    local key="$2"

    case "$manager:$key" in
        apt:fd) printf 'fd-find' ;;
        dnf:fd) printf 'fd-find' ;;
        *:rg) printf 'ripgrep' ;;
        *:*) printf '%s' "$key" ;;
    esac
}

detect_linux_manager() {
    local manager

    for manager in apt-get dnf pacman zypper apk; do
        if command -v "$manager" >/dev/null 2>&1; then
            case "$manager" in
                apt-get) printf 'apt' ;;
                *) printf '%s' "$manager" ;;
            esac
            return
        fi
    done

    printf 'unknown'
}

print_linux_install_command() {
    local manager="$1"
    shift
    local key package
    local -a packages=()

    for key in "$@"; do
        package="$(linux_package_name "$manager" "$key")"
        packages+=("$package")
    done

    case "$manager" in
        apt)
            printf '  sudo apt-get update && sudo apt-get install -y ca-certificates %s\n' "${packages[*]}"
            ;;
        dnf)
            printf '  sudo dnf install -y ca-certificates %s\n' "${packages[*]}"
            ;;
        pacman)
            printf '  sudo pacman -Syu --needed ca-certificates %s\n' "${packages[*]}"
            ;;
        zypper)
            printf '  sudo zypper install -y ca-certificates %s\n' "${packages[*]}"
            ;;
        apk)
            printf '  sudo apk add ca-certificates %s\n' "${packages[*]}"
            ;;
        *)
            printf '  Install these packages with your distribution package manager: %s\n' "${packages[*]}"
            ;;
    esac
}

report_zsh_stack() {
    local omz_home="${ZSH:-$HOME/.oh-my-zsh}"
    local custom_home="${ZSH_CUSTOM:-$omz_home/custom}"
    local p10k_home="$custom_home/themes/powerlevel10k"

    section "Zsh framework"

    if [[ -r "$omz_home/oh-my-zsh.sh" ]]; then
        present "Oh My Zsh" "$omz_home"
    else
        missing "Oh My Zsh" "$omz_home"
        printf '\n%sCopy to install Oh My Zsh:%s\n' "$C_CYAN" "$C_RESET"
        printf '  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"\n'
    fi

    if [[ -r "$p10k_home/powerlevel10k.zsh-theme" ]]; then
        present "Powerlevel10k" "$p10k_home"
    else
        missing "Powerlevel10k" "$p10k_home"
        printf '\n%sCopy to install Powerlevel10k:%s\n' "$C_CYAN" "$C_RESET"
        printf '  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"\n'
    fi

    if [[ "${SHELL:-}" == */zsh ]]; then
        present "Default shell" "${SHELL:-zsh}"
    else
        missing "Default shell" "current: ${SHELL:-unknown}"
        printf '\n%sCopy after Zsh is installed:%s\n' "$C_CYAN" "$C_RESET"
        printf '  chsh -s "$(command -v zsh)"\n'
    fi
}

report_linux() {
    local manager
    INSTALL_ITEMS=()

    section "Environment"
    present "Profile" "$PROFILE"
    manager="$(detect_linux_manager)"
    present "Package manager" "$manager"

    section "Required binaries"
    check_linux_requirement "Bash" bash bash
    check_linux_requirement "Git" git git
    check_linux_requirement "curl" curl curl
    check_linux_requirement "Nano" nano nano
    check_linux_requirement "fzf" fzf fzf
    check_linux_requirement "ripgrep" rg rg
    check_linux_requirement "fd" fd fd fdfind
    check_linux_requirement "bat" bat bat batcat
    check_linux_requirement "less" less less
    check_linux_requirement "Zsh" zsh zsh

    if ((${#INSTALL_ITEMS[@]})); then
        printf '\n%sCopy to install missing packages:%s\n' "$C_CYAN" "$C_RESET"
        print_linux_install_command "$manager" "${INSTALL_ITEMS[@]}"
    else
        printf '\nAll required binaries are available.\n'
    fi

    report_zsh_stack
}

check_git_bash_requirement() {
    local label="$1"
    local winget_id="$2"
    shift 2
    local path

    if path="$(first_command "$@")"; then
        present "$label" "$path"
    else
        missing "$label" "expected: $*"
        append_unique "$winget_id"
    fi
}

report_git_bash() {
    local id
    INSTALL_ITEMS=()

    section "Environment"
    present "Profile" "git-bash"
    present "MSYSTEM" "${MSYSTEM:-not detected; forced profile}"

    section "Required binaries"
    check_git_bash_requirement "Bash" Git.Git bash
    check_git_bash_requirement "Git" Git.Git git
    check_git_bash_requirement "curl" Git.Git curl
    check_git_bash_requirement "Nano" GNU.Nano nano
    check_git_bash_requirement "fzf" junegunn.fzf fzf
    check_git_bash_requirement "ripgrep" BurntSushi.ripgrep.MSVC rg
    check_git_bash_requirement "fd" sharkdp.fd fd
    check_git_bash_requirement "bat" sharkdp.bat bat
    check_git_bash_requirement "less" Git.Git less

    if ((${#INSTALL_ITEMS[@]})); then
        printf '\n%sCopy missing WinGet commands:%s\n' "$C_CYAN" "$C_RESET"
        for id in "${INSTALL_ITEMS[@]}"; do
            printf '  winget.exe install --exact --id %s\n' "$id"
        done
        printf '\nRestart Git Bash after WinGet changes PATH.\n'
    else
        printf '\nAll required binaries are available.\n'
    fi

    if [[ -e /dev/clipboard ]]; then
        present "Clipboard" "/dev/clipboard"
    else
        missing "Clipboard" "/dev/clipboard is unavailable outside Git Bash"
    fi
}

printf '%sDotprofile prerequisite report%s\n' "$C_BOLD" "$C_RESET"
printf 'Read-only: no packages, files, shells, or settings will be changed.\n'

case "$PROFILE" in
    wsl-zsh|linux-zsh) report_linux ;;
    git-bash) report_git_bash ;;
esac

printf '\nNo changes were made.\n'
