#!/usr/bin/env bash

__git_branch() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    local branch
    branch="$(
        git symbolic-ref --quiet --short HEAD 2>/dev/null ||
            git rev-parse --short HEAD 2>/dev/null
    )"

    [[ -n "$branch" ]] && printf ' (%s)' "$branch"
}

set_gitbash_prompt() {
    local branch user_str host_str path_disp date_str cols left right fill_len filler spaces
    local blue green red white yellow dim reset

    branch="$(__git_branch)"
    blue='\[\e[1;34m\]'
    green='\[\e[1;32m\]'
    red='\[\e[1;31m\]'
    white='\[\e[1;37m\]'
    yellow='\[\e[33m\]'
    dim='\[\e[90m\]'
    reset='\[\e[0m\]'

    user_str="${USER:-${LOGNAME:-${USERNAME:-user}}}"
    host_str="${HOSTNAME%%.*}"
    [[ -n "$host_str" ]] || host_str="$(hostname 2>/dev/null || printf host)"
    path_disp="${PWD/#$HOME/~}"
    date_str="$(date +'%I:%M:%S %p')"
    cols="${COLUMNS:-80}"

    left="${user_str}@${host_str} | ${path_disp}${branch} "
    right=" ${date_str}"
    fill_len=$((cols - ${#left} - ${#right}))
    filler=""

    if ((fill_len > 0)); then
        printf -v spaces '%*s' "$fill_len" ''
        filler="${spaces// /·}"
    fi

    PS1="${blue}${user_str}${reset}${dim}@${reset}${green}${host_str}${reset} ${dim}|${reset} ${white}\w${reset}${yellow}${branch}${reset} ${dim}${filler} ${date_str}${reset}"$'\n'"${red}❯${reset} "
}

__portable_profile_prompt_command() {
    __profile_history_sync
    set_gitbash_prompt
}

PROMPT_COMMAND="__portable_profile_prompt_command"
