# neovim

Personal Neovim configuration, distributed as a NixOS module.

---

## WSL clipboard

Clipboard reads (`p`, `"+p`, etc.) go through a `wsl-paste` helper.
By default it falls back to `powershell.exe Get-Clipboard`, which adds
~300–700 ms of PowerShell startup overhead on every paste.

Install **[win32yank](https://github.com/equalsraf/win32yank)** on the
Windows host once to get instant clipboard reads:

```powershell
# via Scoop
scoop install win32yank

# or via WinGet
winget install equalsraf.win32yank
```

`win32yank.exe` is a tiny native binary — `wsl-paste` will detect it
automatically and use it instead of PowerShell. No `nixos-rebuild`
needed.
