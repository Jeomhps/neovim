-- Non-Nix plugin bootstrap via vim.pack.add (Neovim 0.11+).
-- On Nix this file is never sourced — the wrapper owns the runtimepath.
--
-- First run:  plugins are downloaded; Neovim will prompt you to restart.
-- Subsequent runs: already-installed packages are added to packpath instantly.

if not vim.pack then
  vim.notify(
    '[bootstrap] vim.pack.add requires Neovim 0.11+. Please upgrade.',
    vim.log.levels.ERROR
  )
  return
end

local gh = 'https://github.com/'

-- Helper: opt plugin entry (lze calls packadd when its trigger fires).
local function opt(repo, name)
  local t = { src = gh .. repo, data = { opt = true } }
  if name then t.name = name end
  return t
end

vim.pack.add({
  -- ── Lazy-loading framework ─────────────────────────────────────────────────
  -- Start plugins: packadd'd immediately by the load function below so that
  -- require('lze') / require('lzextras') work before lze.load is called.
  gh .. 'BirdeeHub/lze',
  gh .. 'BirdeeHub/lzextras',

  -- ── Colorscheme ────────────────────────────────────────────────────────────
  -- Start: vim.cmd.colorscheme() is called in options.lua before lze.load.
  { src = gh .. 'catppuccin/nvim', name = 'catppuccin-nvim' },

  -- ── UI ─────────────────────────────────────────────────────────────────────
  opt('folke/snacks.nvim'),
  opt('echasnovski/mini.nvim'),
  opt('nvim-lualine/lualine.nvim'),
  opt('lewis6991/gitsigns.nvim'),
  opt('folke/which-key.nvim'),
  opt('j-hui/fidget.nvim'),

  -- ── LSP ────────────────────────────────────────────────────────────────────
  opt('neovim/nvim-lspconfig'),
  opt('folke/lazydev.nvim'),
  opt('williamboman/mason.nvim'),

  -- ── Completion ─────────────────────────────────────────────────────────────
  gh .. 'Saghen/blink.lib',  -- start: must be in rtp before blink.cmp loads
  opt('Saghen/blink.cmp'),
  opt('Saghen/blink.compat'),
  opt('hrsh7th/cmp-cmdline'),
  opt('xzbdmw/colorful-menu.nvim'),

  -- ── Treesitter ─────────────────────────────────────────────────────────────
  opt('nvim-treesitter/nvim-treesitter'),
  opt('nvim-treesitter/nvim-treesitter-textobjects'),

  -- ── Editing ────────────────────────────────────────────────────────────────
  opt('tpope/vim-sleuth'),
  opt('stevearc/conform.nvim'),
  opt('mfussenegger/nvim-lint'),
  opt('kylechui/nvim-surround'),
  opt('dstein64/vim-startuptime'),
}, {
  confirm = false,
  load = function(p)
    -- Start plugins (no opt flag): add to runtimepath immediately.
    if not (p.spec.data or {}).opt then
      vim.cmd.packadd(p.spec.name)
    end
    -- Opt plugins: already in packpath; lze will call packadd on demand.
  end,
})

-- ── blink.cmp native library ──────────────────────────────────────────────────
-- blink.cmp v2 delegates native lib download to blink.lib.native.
-- Replicates lazy.nvim's `build = function() require('blink.cmp').build():wait() end`
-- blink.lib is already packadd'd (start plugin); we just need to temporarily
-- packadd blink.cmp so we can call build(), then let lze manage it from there.
do
  local blink_dir = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/blink.cmp', 0, 1)[1]
  if blink_dir and blink_dir ~= '' then
    pcall(vim.cmd.packadd, 'blink.cmp')
    local ok, cmp = pcall(require, 'blink.cmp')
    if ok and type(cmp.build) == 'function' then
      local build_ok, err = pcall(function() cmp.build():wait(60000) end)
      if not build_ok then
        vim.notify('[bootstrap] blink.cmp build failed: ' .. tostring(err), vim.log.levels.WARN)
      end
    end
  end
end
