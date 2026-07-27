#!/usr/bin/env bash

if command -v cygpath >/dev/null 2>&1 && [[ -n "${USERPROFILE:-}" ]]; then
    _windows_home="$(cygpath -u "$USERPROFILE" 2>/dev/null || true)"
    if [[ -n "$_windows_home" ]]; then
        path_prepend "$_windows_home/scoop/shims"
        path_prepend "$_windows_home/AppData/Local/Microsoft/WinGet/Links"
    fi
    unset _windows_home
fi
