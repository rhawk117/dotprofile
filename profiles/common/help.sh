#!/usr/bin/env bash

profile-help() {
    cat <<'EOF'
Dotprofile command reference

Profile management
  profile-help              Show this reference
  profile-doctor            Check tools, clipboard, and installed files
  reload                    Reload the current shell configuration
  catrc                     Print the current shell startup file
  editrc                    Edit the current shell startup file
  profiles                  Enter ~/.configs/profiles

Daily navigation
  mkcd DIR                  Create and enter a directory
  croot                     Enter the current Git repository root
  upby COUNT                Move up COUNT directories
  bkmark                    Bookmark the current directory
  bkmark go                 Return to the bookmarked directory
  bkmark show               Print the current bookmark
  bkmark clear              Clear the current bookmark
  pathlines                 Print PATH one entry per line

Git workflows
  gitsnap -m MESSAGE        Stage all and commit
  gitsnap -m MSG -a PATH   Stage selected paths and commit
  gitsnap -m MSG -s -p     Sync, commit, and push
  gitfeat -b BRANCH -r BASE
                            Update BASE and create BRANCH from it
  fzgc                      Fuzzy-select a Git branch

Fuzzy workflows
  fzhelp                    Show every fuzzy command
  fzcd [ROOT]               Select and enter a directory
  fznano [ROOT]             Select a file and open it in Nano
  fzvs [ROOT]               Select a path and open it in VS Code
  fzless [ROOT]             Select a file and open it in less
  fzmore [ROOT]             Select a file and open it in more
  fzgrep TEXT [ROOT]        Search content and open the selected match
  fzh                       Search and execute command history
  fzps [--pid-only]         Browse processes or print a PID
  fzclip                    Select one stdin line and copy it

Files and search
  lstree [PATH]             Recursive detailed ls view
  tree [PATH]               Use tree, falling back to lstree
  rglob PATTERN [TYPE]      Find names recursively
  gr PATTERN [PATH]         Search recursively with ripgrep
  gri PATTERN [PATH]        Case-insensitive recursive search
  extract ARCHIVE           Extract a common archive format
  biggest                   Show the 50 largest entries below cwd

Clipboard and Windows
  copy                      Read stdin into the system clipboard
  paste                     Print the system clipboard
  openwin PATH_OR_URL       Open a path or URL through Windows
  winpath PATH              Convert a shell path to a Windows path
  unixpath PATH             Convert a Windows path to a shell path

Powerlevel10k, WSL Zsh only
  p10k-help                 Show saved-theme commands and workflow
  p10k-new                  Run the wizard after backing up the current config
  p10k-save NAME            Save ~/.p10k.zsh as NAME
  p10k-list                 List saved configurations
  p10k-use NAME             Activate a saved configuration
  p10k-edit [NAME]          Edit the active or named configuration

More specific help
  fzhelp
  p10k-help
  gitsnap --help
  gitfeat --help
  bkmark --help
EOF
}
