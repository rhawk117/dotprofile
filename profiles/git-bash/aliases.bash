#!/usr/bin/env bash

alias activate='source .venv/Scripts/activate'

alias explorer='openwin'
alias open='openwin'
alias clip='copy'

alias hosts='${EDITOR:-nano} /c/Windows/System32/drivers/etc/hosts'
alias desktop='cd "$(cygpath -u "$USERPROFILE")/Desktop"'
alias downloads='cd "$(cygpath -u "$USERPROFILE")/Downloads"'

alias ipconfig='ipconfig.exe'
alias wintasks='tasklist.exe'
alias killtask='taskkill.exe'
alias wherewin='where.exe'
alias winget='winget.exe'
alias notepad='notepad.exe'
alias winpwd='winpath "$PWD"'
