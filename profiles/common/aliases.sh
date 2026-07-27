#!/usr/bin/env bash

# Startup files
alias bashrc='${EDITOR:-nano} "$HOME/.bashrc"'
alias zshrc='${EDITOR:-nano} "${ZDOTDIR:-$HOME}/.zshrc"'
alias nanorc='${EDITOR:-nano} "$HOME/.nanorc"'
alias gitconfig='${EDITOR:-nano} "$HOME/.gitconfig"'
alias profiles='cd "$SHELL_CONFIG_HOME/profiles"'

# Navigation
alias up='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias cls='clear'
alias q='exit'

# GNU ls on both supported environments
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias dir='ls -C'
alias lsd='ls -lah --directory */ 2>/dev/null'

# Filesystem: retained from the original profile
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'
alias rmi='rm -Iv'

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias more='less -R'

# Disk
alias df='df -h'
alias du='du -h'
alias dus='du -sh -- * 2>/dev/null | sort -h'
alias biggest='du -ah . 2>/dev/null | sort -rh | head -n 50'

# Processes
alias psa='ps aux'

# History and time
alias h='history'
alias now='date +"%Y-%m-%d %I:%M:%S %p"'
alias week='date +%V'

# Git: retained originals plus a few non-destructive helpers
alias gs='git status --short'
alias gstatus='git status'
alias gaa='git add --all'
alias gap='git add --patch'
alias gc='git checkout'
alias gsw='git switch'
alias grs='git restore'
alias grst='git restore --staged'
alias glog='git log --graph --oneline --decorate'
alias gloga='git log --graph --oneline --decorate --all'
alias gpull='git pull'
alias gpush='git push'
alias gcommit='git commit -m'
alias gdiff='git diff'
alias gds='git diff --staged'
alias gbranch='git branch'
alias gfetch='git fetch --all --prune --prune-tags'
alias gamend='git commit --amend --no-edit'
alias groot='cd "$(git rev-parse --show-toplevel)"'

# GitHub CLI
alias ghpr='gh pr view --web'
alias ghprs='gh pr status'
alias ghissues='gh issue list'

# Python and UV
alias py='python3'
alias pyr='python3 -m'
alias uvr='uv run'
alias uvs='uv sync'
alias uva='uv add'
alias uvad='uv add --dev'
alias uvl='uv lock'
alias uvt='uv run pytest'
alias uvrf='uv run ruff format'
alias uvrl='uv run ruff check'

# Docker
alias d='docker'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcb='docker compose build'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kga='kubectl get all'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'
alias kns='kubectl config set-context --current --namespace'

# Jira
alias jme='jira me'
alias jil='jira issue list'
alias jiv='jira issue view'
alias jic='jira issue create'
