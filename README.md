# neovim

Personal Neovim configuration, distributed as a NixOS module.  
Built on [`lze`](https://github.com/BirdeeHub/lze) + [`lzextras`](https://github.com/BirdeeHub/lzextras) for lazy-loading, with first-class Nix support via `nixInfo` — but also works on non-Nix systems via a bootstrap script.

---

## Table of Contents

- [Features](#features)
- [Plugin Overview](#plugin-overview)
- [Key Mappings (quick reference)](#key-mappings-quick-reference)
- [Where to add things](#where-to-add-things)
- [WSL Clipboard](#wsl-clipboard)

---

## Features

| Area | Tool |
|---|---|
| Plugin loader | `lze` + `lzextras` |
| Colorscheme | `catppuccin` (mocha by default, Nix-configurable) |
| LSP | `nvim-lspconfig` + `Mason` (non-Nix fallback) |
| Completion | `blink.cmp` (with cmdline + colorful labels) |
| Fuzzy finder | `Snacks.picker` |
| File explorer | `Snacks.explorer` (replaces netrw) |
| Terminal | `Snacks.terminal` |
| Git signs | `gitsigns.nvim` |
| Git UI | `LazyGit` (via Snacks) |
| Formatter | `conform.nvim` |
| Linter | `nvim-lint` |
| Syntax / folds | `nvim-treesitter` + text objects |
| Statusline | `lualine.nvim` (with buffer tabline) |
| Icons | `mini.icons` |
| Surround | `nvim-surround` |
| LSP progress | `fidget.nvim` |
| Keybinding hints | `which-key.nvim` |
| Indent guides | `Snacks.indent` |
| Startup profiling | `vim-startuptime` |
| Clipboard (WSL) | `wsl-paste` / `win32yank` |

---

## Plugin Overview

### `lua/plugins/snacks.lua`
Lazy keymaps for **Snacks.nvim** (explorer, terminal, LazyGit, and all picker bindings).  
The early *setup* (indent guides, statuscolumn, `replace_netrw`) lives in `lua/config/snacks.lua` and is sourced synchronously from `init.lua` before `VimEnter`.

### `lua/plugins/lsp.lua`
- Global `on_attach` keymaps wired via `vim.lsp.config('*', …)`.
- **Mason** auto-installs servers on non-Nix.
- **lazydev.nvim** for enhanced Lua LSP inside this config.
- LSP servers are individual `lze` specs — add a new block here to enable a server.

### `lua/plugins/completion.lua`
**blink.cmp** with:
- Sources: LSP, path, buffer, omni, cmdline.
- `colorful-menu.nvim` for syntax-highlighted completion labels.
- Signature help and auto-documentation enabled.

### `lua/plugins/treesitter.lua`
- **nvim-treesitter** auto-attaches and auto-installs parsers on `FileType`.
- Tree-sitter folding enabled per window.
- **nvim-treesitter-textobjects** — `am/im` (function), `ac/ic` (class), `as` (scope).

### `lua/plugins/ui.lua`
`mini.icons`, `fidget.nvim`, `lualine.nvim`, `gitsigns.nvim`, `which-key.nvim`.

### `lua/plugins/editing.lua`
`conform.nvim` (formatting), `nvim-lint` (linting), `nvim-surround`, `vim-startuptime`.

---

## Key Mappings (quick reference)

`<leader>` is `Space`.

### General
| Key | Action |
|---|---|
| `<Esc>` | Clear search highlight |
| `<C-d>` / `<C-u>` | Scroll down/up (centered) |
| `n` / `N` | Next/prev search result (centered) |
| `J` / `K` (visual) | Move selection down/up |
| `<leader>e` | Floating diagnostic |
| `<leader>q` | Diagnostics location list |
| `<leader>y/Y` | Yank to system clipboard |
| `<leader>p` | Paste from system clipboard |
| `<leader>FF` | Format file (conform + LSP fallback) |

### Buffers (`<leader><leader>`)
| Key | Action |
|---|---|
| `<leader><leader>[` | Previous buffer |
| `<leader><leader>]` | Next buffer |
| `<leader><leader>l` | Last buffer |
| `<leader><leader>d` | Delete buffer |
| `<leader><leader>s` | Search open buffers |

### Files & Search (`<leader>f` / `<leader>s`)
| Key | Action |
|---|---|
| `-` | File explorer |
| `<leader>sf` | Smart find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Find git files |
| `<leader>sg` | Grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>sb` | Buffer lines |
| `<leader>sB` | Grep open buffers |
| `<leader>sd` / `<leader>sD` | Workspace / buffer diagnostics |
| `<leader>sh` | Help pages |
| `<leader>sk` | Keymaps |
| `<leader>sm` | Marks |
| `<leader>sM` | Man pages |
| `<leader>su` | Undo history |
| `<leader>sR` | Resume last picker |

### LSP
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gI` | Implementations |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |

### Git (`<leader>g`)
| Key | Action |
|---|---|
| `<leader>_` | LazyGit |
| `]c` / `[c` | Next/prev hunk |
| `<leader>gs` / `<leader>gr` | Stage/reset hunk |
| `<leader>gS` / `<leader>gR` | Stage/reset buffer |
| `<leader>gu` | Undo stage hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |
| `<leader>gd` / `<leader>gD` | Diff index / last commit |
| `<leader>gtb` | Toggle line blame |
| `<leader>gtd` | Toggle deleted |

### Terminal
| Key | Action |
|---|---|
| `<C-\>` | Toggle terminal |

---

## Where to add things

### ➕ New LSP server
Add a spec in **`lua/plugins/lsp.lua`**:
```neovim/nvim/lua/plugins/lsp.lua#L1-1
-- example:
{
  "ts_ls",
  for_cat = "typescript",   -- optional: tie to a Nix cat
  mason = "typescript-language-server",  -- Mason package name (non-Nix)
  lsp = {
    filetypes = { "typescript", "javascript" },
  },
},
```
On Nix, also add the server to your `module.nix` under the appropriate category.

### ➕ New formatter
Add an entry in **`lua/plugins/editing.lua`** inside `conform.setup({ formatters_by_ft = { … } })`:
```neovim/nvim/lua/plugins/editing.lua#L1-1
-- example:
go = { "gofmt" },
python = { "black" },
```

### ➕ New linter
Add an entry in **`lua/plugins/editing.lua`** inside `lint.linters_by_ft = { … }`:
```neovim/nvim/lua/plugins/editing.lua#L1-1
-- example:
javascript = { "eslint" },
python = { "flake8" },
```

### ➕ New plugin (generic)
Add a spec to the most relevant file under **`lua/plugins/`**, or create a new file and add `{ import = "plugins.myfile" }` in `init.lua`:
```neovim/nvim/init.lua#L1-1
-- in the lze.load block at the bottom of init.lua:
{ import = "plugins.myfile" },
```
Use `auto_enable = true` so the plugin is gracefully disabled when not installed on Nix.

### ➕ New keymap (no plugin dependency)
Add it to **`lua/config/keymaps.lua`**.

### ➕ New autocommand
Add it to **`lua/config/autocmds.lua`**.

### ➕ New vim option
Add it to **`lua/config/options.lua`**.

---

## WSL Clipboard

Clipboard reads (`p`, `"+p`, etc.) go through a `wsl-paste` helper.
By default it falls back to `powershell.exe Get-Clipboard`, which adds
~300–700 ms of PowerShell startup overhead on every paste.

Install **[win32yank](https://github.com/equalsraf/win32yank)** on the
Windows host once to get instant clipboard reads:

```neovim/README.md#L1-1
# via Scoop
scoop install win32yank

# or via WinGet
winget install equalsraf.win32yank
```

`win32yank.exe` is a tiny native binary — `wsl-paste` will detect it
automatically and use it instead of PowerShell. No `nixos-rebuild` needed.
