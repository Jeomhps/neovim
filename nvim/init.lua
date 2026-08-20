vim.loader.enable() -- bytecode caching

if not require('engine').ready then
  return
end

-- leader must be set before any plugin keymaps are registered
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- On Nix, the wrapper points rtp at this repo directly without touching
-- stdpath, so vim.fn.stdpath('config') would resolve to the (nonexistent)
-- default ~/.config/nvim. On non-Nix, stdpath('config') is correct as-is.
if nixInfo.isNix then
  nixInfo.config_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')
else
  nixInfo.config_dir = vim.fn.stdpath('config')
end

-- ── core config ───────────────────────────────────────────────────────────────
require("config.options")   -- vim options + synchronous colorscheme (no flash)
require("config.keymaps")   -- base keymaps (no plugin dependencies)
require("config.autocmds")  -- autocommands

-- Snacks must be set up synchronously before VimEnter so that replace_netrw,
-- statuscolumn, and indent hooks are registered at the right time.
-- On Nix:     get_nix_plugin_path returns the store path → packadd it.
-- On non-Nix: bootstrap placed it in packpath as opt → packadd it the same way.
if nixInfo.get_nix_plugin_path('snacks.nvim') or not nixInfo.isNix then
  if pcall(vim.cmd.packadd, 'snacks.nvim') then
    require('config.snacks')
  end
end

-- ── plugin specs (each file returns a table of lze specs) ─────────────────────
nixInfo.lze.load {
  { import = "plugins.snacks"     },
  { import = "plugins.lsp"        },
  { import = "plugins.treesitter" },
  { import = "plugins.completion" },
  { import = "plugins.ui"         },
  { import = "plugins.editing"    },
}
