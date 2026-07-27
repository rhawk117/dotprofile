#!/usr/bin/env bash

# Shared daily utilities for Bash and Zsh.

__BKMARK_PATH="${__BKMARK_PATH:-}"

rc_info() { printf '\033[34m[info]\033[0m %s\n' "$*"; }
rc_success() { printf '\033[32m[ok]\033[0m %s\n' "$*"; }
rc_warn() { printf '\033[33m[warn]\033[0m %s\n' "$*" >&2; }
rc_error() { printf '\033[31m[error]\033[0m %s\n' "$*" >&2; }

if [[ -n "${NO_COLOR:-}" || ! -t 1 ]]; then
    rc_info() { printf '[info] %s\n' "$*"; }
    rc_success() { printf '[ok] %s\n' "$*"; }
    rc_warn() { printf '[warn] %s\n' "$*" >&2; }
    rc_error() { printf '[error] %s\n' "$*" >&2; }
fi

gitsnap() {
    local message=""
    local do_sync=0
    local do_push=0
    local -a paths
    paths=(.)

    while (($#)); do
        case "$1" in
            -h|--help)
                cat <<'EOF'
Usage: gitsnap -m MESSAGE [-s|--sync] [-p|--push] [-a|--add PATH ...]

Stage selected paths, commit them, and optionally sync or push.

Examples:
  gitsnap -m "fix prompt"
  gitsnap -m "update profiles" --sync --push
  gitsnap -m "docs only" --add README.md docs/
EOF
                return
                ;;
            -m|--message)
                [[ $# -ge 2 ]] || { rc_error "$1 requires a message"; return 2; }
                message="$2"
                shift 2
                ;;
            -s|--sync)
                do_sync=1
                shift
                ;;
            -p|--push)
                do_push=1
                shift
                ;;
            -a|--add)
                shift
                paths=()
                while (($#)) && [[ "$1" != -* ]]; do
                    paths+=("$1")
                    shift
                done
                ((${#paths[@]})) || { rc_error "--add requires at least one path"; return 2; }
                ;;
            *)
                rc_error "unknown option: $1"
                return 2
                ;;
        esac
    done

    [[ -n "$message" ]] || { rc_error "commit message required; run gitsnap --help"; return 2; }
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { rc_error "not inside a Git repository"; return 1; }

    if ((do_sync)); then
        git pull --rebase --autostash || return
    fi

    git add -- "${paths[@]}" || return

    if git diff --cached --quiet; then
        rc_warn "nothing staged"
        return 1
    fi

    git commit -m "$message" || return

    if ((do_push)); then
        git push || return
    fi
}

gitfeat() {
    local branch=""
    local base=""

    while (($#)); do
        case "$1" in
            -h|--help)
                printf 'Usage: gitfeat -b BRANCH -r BASE\n'
                return
                ;;
            -b|--branch)
                branch="${2:-}"
                shift 2
                ;;
            -r|--base)
                base="${2:-}"
                shift 2
                ;;
            *)
                rc_error "unknown option: $1"
                return 2
                ;;
        esac
    done

    [[ -n "$branch" && -n "$base" ]] || { rc_error "both --branch and --base are required"; return 2; }

    git fetch origin "$base" || return
    git switch "$base" || return
    git pull --ff-only origin "$base" || return
    git switch -c "$branch"
}

upby() {
    local count="${1:-1}"
    [[ "$count" =~ ^[0-9]+$ ]] || { rc_error "usage: upby COUNT"; return 2; }

    while ((count-- > 0)); do
        cd .. || return
    done
}

rglob() {
    local pattern="${1:-}"
    local type="${2:-f}"

    [[ -n "$pattern" ]] || { rc_error "usage: rglob PATTERN [TYPE]"; return 2; }
    find . -type "$type" -name "$pattern"
}

gr() {
    [[ $# -ge 1 ]] || { rc_error "usage: gr PATTERN [PATH]"; return 2; }
    rg --hidden --glob '!.git/**' -- "$1" "${2:-.}"
}

gri() {
    [[ $# -ge 1 ]] || { rc_error "usage: gri PATTERN [PATH]"; return 2; }
    rg -i --hidden --glob '!.git/**' -- "$1" "${2:-.}"
}

bkmark() {
    local action="${1:-path}"

    case "$action" in
        path|-p|set)
            __BKMARK_PATH="$PWD"
            export __BKMARK_PATH
            rc_success "bookmarked: $__BKMARK_PATH"
            ;;
        go|-g)
            [[ -n "$__BKMARK_PATH" ]] || { rc_error "bookmark is unset"; return 1; }
            cd -- "$__BKMARK_PATH" || return
            rc_info "opened bookmark: $__BKMARK_PATH"
            ;;
        show|-s)
            printf '%s\n' "${__BKMARK_PATH:-none}"
            ;;
        clear|-c)
            __BKMARK_PATH=""
            export __BKMARK_PATH
            rc_success "bookmark cleared"
            ;;
        help|-h|--help)
            cat <<'EOF'
Usage: bkmark [path|go|show|clear]

Commands:
  path, set   Bookmark the current directory; this is the default
  go          Change to the bookmarked directory
  show        Print the bookmarked directory
  clear       Clear the bookmark
EOF
            ;;
        *)
            rc_error "unknown bkmark action: $action"
            return 2
            ;;
    esac
}
