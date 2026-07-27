#!/usr/bin/env zsh

alias bat='batcat'
alias fd='fdfind'

alias activate='source .venv/bin/activate'
alias hosts='sudo ${EDITOR:-nano} /etc/hosts'

alias aptup='sudo apt update && sudo apt upgrade'
alias apti='sudo apt install'
alias aptr='sudo apt remove'
alias aptsearch='apt search'

alias explorer='openwin'
alias clip='copy'
alias ip='ip -color=auto'

alias winip='ipconfig.exe'
alias wintasks='tasklist.exe'
alias wslshutdown='wsl.exe --shutdown'
alias winpwd='winpath "$PWD"'
