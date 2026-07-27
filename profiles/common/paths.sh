#!/usr/bin/env bash

path_prepend() {
    local directory="${1:-}"
    [[ -n "$directory" && -d "$directory" ]] || return 0

    case ":$PATH:" in
        *":$directory:"*) ;;
        *) PATH="$directory${PATH:+:$PATH}" ;;
    esac
}

path_append() {
    local directory="${1:-}"
    [[ -n "$directory" && -d "$directory" ]] || return 0

    case ":$PATH:" in
        *":$directory:"*) ;;
        *) PATH="${PATH:+$PATH:}$directory" ;;
    esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.local/share/uv/tools"
path_prepend "$HOME/.bun/bin"

export PATH
