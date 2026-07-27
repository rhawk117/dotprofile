# Portable shell profiles

A copied, non-symlinked shell configuration bundle for:

- WSL with Zsh and an existing Powerlevel10k prompt
- Git Bash with a custom two-line prompt
- Shared GNU-style aliases and functions
- Nano with modern keyboard bindings
- Git global defaults and aliases
- fzf, fd, ripgrep, bat, Docker, Kubernetes, UV, Jira, and GitHub CLI helpers

The installer copies managed files into `~/.configs`, backs up anything it
replaces, and adds small managed include blocks to your existing startup files.
It does **not** replace your `.zshrc`, `.bashrc`, `.gitconfig`, `.nanorc`, or
`.inputrc`.

## Install

```bash
cd dotprofile
bash install.sh
```

Automatic detection chooses:

- `wsl-zsh` when running inside WSL
- `git-bash` when `MSYSTEM` identifies Git Bash

Explicit selection:

```bash
bash install.sh --profile wsl-zsh
bash install.sh --profile git-bash
```

Preview without changing anything:

```bash
bash install.sh --dry-run
```

The default target is `~/.configs`. A different target is supported:

```bash
bash install.sh --target "$HOME/.configs"
```

## Dependencies

The installer reports missing commands but deliberately does not install
packages. Package installation is platform policy, not something a dotfiles
script should improvise while holding your home directory.

Expected tools:

- Both: `git`, `nano`, `fzf`, `rg`, `less`
- WSL defaults: `fdfind`, `batcat`
- Git Bash defaults: `fd`, `bat`
- Optional: `tree`, `kubectl`, `docker`, `gh`, `jira`, `uv`

For WSL clipboard paste, install one of:

1. `win32yank.exe`
2. `wl-paste`
3. `xclip`
4. `xsel`

Copy always uses `clip.exe` when available. Git Bash reads and writes
`/dev/clipboard` directly.

## Important behavior

The shared profile intentionally keeps your original command overrides:

```text
cat -> bat/batcat when available
cp  -> cp -v
mv  -> mv -v
rm  -> rm -v
```

`cat` falls back to the real command if bat is unavailable. Use `rawcat` when
you explicitly need the original command.

`lstree` is the requested recursive GNU `ls` view:

```bash
lstree
lstree src
```

It uses:

```text
ls -lahR --group-directories-first --time-style=long-iso --color=auto
```

`tree` uses the real `tree` program when installed and falls back to `lstree`.

## Nano bindings

The explicit bindings work on older Nano releases that predate Nano 8's
`modernbindings` option.

| Action        | Binding              |
| ------------- | -------------------- |
| Select / mark | `Ctrl+A`             |
| Copy          | `Ctrl+C`             |
| Cut           | `Ctrl+X`             |
| Paste         | `Ctrl+V` or `Ctrl+P` |
| Undo          | `Ctrl+Z`             |
| Redo          | `Ctrl+Y`             |
| Search        | `Ctrl+F`             |
| Save          | `Ctrl+S`             |
| Exit          | `Ctrl+Q` or `F10`    |

Bare Escape cannot be bound because terminals use it to begin Meta keys and
escape sequences. The shared shell profile runs `stty -ixon`, freeing
`Ctrl+S` and `Ctrl+Q` from terminal flow control.

## Useful helpers

```bash
reload                 # Reload the active shell startup file
catrc                   # Print the active startup file
editrc                  # Edit the active startup file
mkcd path               # Create and enter a directory
croot                   # Enter the current Git repository root
extract archive         # Extract common archive formats
pathlines               # Print PATH one entry per line
fcd                      # Fuzzy-select and enter a directory
fe                       # Fuzzy-select a file and edit it
fif pattern              # Search file contents and select a result
copy < file              # Copy stdin to the system clipboard
paste                    # Print the system clipboard
openwin path-or-url      # Open through Windows
winpath path             # Convert to a Windows path
unixpath path            # Convert to a shell path
profile-doctor           # Check configuration and optional tools
```

## Updating

Run the new bundle's installer again. Existing managed directories are copied
to:

```text
~/.configs/.backups/YYYYMMDD-HHMMSS/
```

The managed blocks in startup files are replaced idempotently instead of being
duplicated.

## Uninstall

Remove include blocks but retain the copied configuration:

```bash
bash uninstall.sh
```

Also remove the managed configuration directories:

```bash
bash uninstall.sh --purge
```
