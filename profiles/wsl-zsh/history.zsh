#!/usr/bin/env zsh

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"

HISTSIZE=50000
SAVEHIST=50000

# Append each command when it completes without continuously importing and
# rewriting history from every other active shell. SHARE_HISTORY made command
# entry noticeably less responsive on filesystems where metadata writes are
# comparatively expensive, including WSL-mounted environments.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
unsetopt SHARE_HISTORY

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
