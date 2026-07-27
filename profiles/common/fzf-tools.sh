#!/usr/bin/env bash

# Shared fzf workflows for Bash and Zsh.

: "${FZ_IGNORE_DIRS:=.git node_modules .svn .hg __pycache__ .cache .tox .mypy_cache .pytest_cache .venv venv dist build .next .nuxt target}"
export FZ_IGNORE_DIRS

__fz_has() {
    command -v "$1" >/dev/null 2>&1
}

__fz_require() {
    local command_name
    local missing=0

    for command_name in "$@"; do
        if ! __fz_has "$command_name"; then
            rc_error "missing required command: $command_name"
            missing=1
        fi
    done

    return "$missing"
}

__fz_find() {
    local root="${1:-.}"
    shift || true

    local -a command_args
    local ignored
    command_args=("$root")

    if [[ -n "${FZ_IGNORE_DIRS:-}" ]]; then
        command_args+=("(")
        for ignored in $FZ_IGNORE_DIRS; do
            if [[ "${command_args[-1]}" != "(" ]]; then
                command_args+=("-o")
            fi
            command_args+=("-name" "$ignored")
        done
        command_args+=(")" "-prune" "-o")
    fi

    find "${command_args[@]}" "$@" -print 2>/dev/null
}

__fz_preview() {
    local path="$1"
    local lines="${2:-100}"

    if [[ -d "$path" ]]; then
        command ls -lah --color=always "$path" 2>/dev/null
    elif [[ -f "$path" ]]; then
        if command -v "${BAT_BIN:-bat}" >/dev/null 2>&1; then
            "${BAT_BIN:-bat}" --color=always --style=numbers --line-range=":$lines" "$path"
        else
            sed -n "1,${lines}p" "$path"
        fi
    else
        printf 'cannot preview: %s\n' "$path"
    fi
}

__fz_files() {
    local root="${1:-.}"
    if command -v "${FD_BIN:-fd}" >/dev/null 2>&1; then
        "${FD_BIN:-fd}" --type f --hidden --follow --exclude .git . "$root"
    else
        __fz_find "$root" -type f
    fi
}

__fz_dirs() {
    local root="${1:-.}"
    if command -v "${FD_BIN:-fd}" >/dev/null 2>&1; then
        "${FD_BIN:-fd}" --type d --hidden --follow --exclude .git . "$root"
    else
        __fz_find "$root" -type d
    fi
}

__fz_open_line() {
    local file="$1"
    local line="${2:-1}"
    local editor="${3:-${EDITOR:-nano}}"

    case "$editor" in
        code|vscode|vs)
            code -g "$file:$line"
            ;;
        nano)
            nano "+$line" "$file"
            ;;
        *)
            "$editor" "+$line" "$file"
            ;;
    esac
}

fzls() {
    local root="${1:-.}"
    __fz_require fzf find || return

    __fz_find "$root" \( -type f -o -type d -o -type l \) |
        fzf --multi \
            --prompt='files> ' \
            --preview='if [ -d {} ]; then ls -lah --color=always {}; elif command -v bat >/dev/null 2>&1; then bat --color=always --style=numbers --line-range=:100 {}; else sed -n "1,100p" {}; fi'
}

fzinfo() {
    local root="${1:-.}"
    __fz_require fzf find || return

    __fz_find "$root" \( -type f -o -type d -o -type l \) |
        fzf --multi \
            --prompt='info> ' \
            --preview='printf "Path: %s\n\n" {}; ls -lah --color=always {}; printf "\n"; file {}; printf "\n"; stat {}'
}

fzcd() {
    local root="${1:-.}"
    local selected

    __fz_require fzf || return
    selected="$(__fz_dirs "$root" | fzf --prompt='cd> ' --preview='ls -lah --color=always {}')" || return
    [[ -n "$selected" ]] && cd -- "$selected"
}

fznano() {
    local selected

    __fz_require fzf nano || return
    selected="$(__fz_files "${1:-.}" | fzf --prompt='nano> ' --preview="${BAT_BIN:-bat} --color=always --style=numbers --line-range=:200 {} 2>/dev/null || sed -n '1,200p' {}")" || return
    [[ -n "$selected" ]] && nano "$selected"
}

fzvs() {
    local selected

    __fz_require fzf code || return
    selected="$(__fz_find "${1:-.}" \( -type f -o -type d \) | fzf --prompt='code> ' --preview='if [ -d {} ]; then ls -lah --color=always {}; else sed -n "1,100p" {}; fi')" || return
    [[ -n "$selected" ]] && code "$selected"
}

fzless() {
    local selected

    __fz_require fzf less || return
    selected="$(__fz_files "${1:-.}" | fzf --prompt='less> ' --preview="${BAT_BIN:-bat} --color=always --style=numbers --line-range=:200 {} 2>/dev/null || sed -n '1,200p' {}")" || return
    [[ -n "$selected" ]] && less "$selected"
}

fzclip() {
    local selected

    __fz_require fzf || return
    selected="$(fzf --prompt='copy> ')" || return
    [[ -n "$selected" ]] || return
    printf '%s' "$selected" | copy
    rc_success "copied selection"
}

fzh() {
    local selected

    __fz_require fzf || return
    selected="$(fc -rl 1 2>/dev/null | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' | awk '!seen[$0]++' | fzf --tac --prompt='history> ')" || return
    [[ -n "$selected" ]] || return
    printf '%s\n' "$selected"
    eval "$selected"
}

fzgc() {
    local branch

    __fz_require fzf git || return
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { rc_error "not inside a Git repository"; return 1; }

    branch="$(
        git for-each-ref --format='%(refname:short)' refs/heads refs/remotes |
            sed 's#^origin/##' |
            grep -v 'HEAD$' |
            sort -u |
            fzf --prompt='branch> ' \
                --preview='git log --oneline --decorate --graph --color=always {} -- 2>/dev/null | head -80'
    )" || return

    [[ -n "$branch" ]] && git switch "$branch"
}

fzgrep() {
    local pattern="${1:-}"
    local root="${2:-.}"
    local selected file line

    [[ -n "$pattern" ]] || { rc_error "usage: fzgrep PATTERN [PATH]"; return 2; }
    __fz_require fzf rg || return

    selected="$(
        rg --line-number --no-heading --color=always --smart-case -- "$pattern" "$root" |
            fzf --ansi --delimiter=: --prompt='grep> ' \
                --preview="${BAT_BIN:-bat} --color=always --style=numbers --highlight-line {2} --line-range {2}:-50:+100 {1}"
    )" || return

    [[ -n "$selected" ]] || return
    file="${selected%%:*}"
    line="${selected#*:}"
    line="${line%%:*}"
    __fz_open_line "$file" "$line"
}

fzg() {
    fzgrep "$@"
}

fzdiff() {
    local reference="${1:-}"
    local selected

    [[ -f "$reference" ]] || { rc_error "usage: fzdiff REFERENCE_FILE"; return 2; }
    __fz_require fzf diff || return

    selected="$(__fz_files . | fzf --prompt='compare> ' --preview="diff --color=always -u '$reference' {} 2>/dev/null || true")" || return
    [[ -n "$selected" ]] && diff -u "$reference" "$selected"
}

fzcomp() {
    __fz_require fzf || return

    if [[ -n "${ZSH_VERSION:-}" ]]; then
        print -rl -- ${(k)commands} ${(k)aliases} ${(k)functions} |
            sort -u |
            fzf --prompt='command> '
    else
        compgen -c | sort -u | fzf --prompt='command> ' --preview='type {} 2>/dev/null'
    fi
}

fzps() {
    local selected pid

    __fz_require fzf ps || return
    selected="$(
        ps -eo pid=,ppid=,user=,%cpu=,%mem=,etime=,comm=,args= --sort=-%cpu 2>/dev/null |
            fzf --prompt='process> ' \
                --preview='pid=$(awk "{print \$1}" <<< {}); ps -fp "$pid"; command -v pstree >/dev/null && pstree -aps "$pid"; command -v lsof >/dev/null && lsof -p "$pid" | head -40'
    )" || return

    [[ -n "$selected" ]] || return
    pid="$(awk '{print $1}' <<< "$selected")"

    if [[ "${1:-}" == "--pid-only" ]]; then
        printf '%s\n' "$pid"
    else
        printf '%s\n' "$selected"
    fi
}

fzhelp() {
    local command_name="${1:-}"

    if [[ -n "$command_name" ]]; then
        case "$command_name" in
            fzgrep)
                printf 'Usage: fzgrep PATTERN [PATH]\n'
                ;;
            fzdiff)
                printf 'Usage: fzdiff REFERENCE_FILE\n'
                ;;
            fzcd|fzls|fzinfo|fznano|fzvs|fzless)
                printf 'Usage: %s [ROOT]\n' "$command_name"
                ;;
            fzclip|fzh|fzgc|fzcomp|fzps)
                printf 'Usage: %s\n' "$command_name"
                ;;
            *)
                rc_error "unknown fzf command: $command_name"
                return 2
                ;;
        esac
        return
    fi

    cat <<'EOF'
Fuzzy commands

  fzls [ROOT]             Browse files, directories, and links
  fzinfo [ROOT]           Browse filesystem metadata
  fzcd [ROOT]             Select a directory and enter it
  fznano [ROOT]           Select a file and open it in Nano
  fzvs [ROOT]             Select a path and open it in VS Code
  fzless [ROOT]           Select a file and open it in less
  fzclip                   Select one stdin line and copy it
  fzh                      Select and execute shell history
  fzgc                     Select and switch Git branches
  fzgrep PATTERN [PATH]   Search content and open the match
  fzg PATTERN [PATH]      Alias for fzgrep
  fzdiff FILE              Select a file to compare against FILE
  fzcomp                   Browse available commands
  fzps                     Browse processes

Run: fzhelp COMMAND
EOF
}
