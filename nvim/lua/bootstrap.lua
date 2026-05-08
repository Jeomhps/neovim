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
-- vim.pack.add does a plain git clone, so the prebuilt Rust fuzzy-match
-- library is never present.  Download the correct asset from GitHub Releases.
do
  -- 1. Locate the installed plugin directory.
  local blink_dir = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/blink.cmp', 0, 1)[1]
  if not blink_dir or blink_dir == '' then
    -- Not installed yet (first run) — vim.pack.add is still downloading.
    -- The binary will be fetched on the next restart after plugins are present.
    goto blink_done
  end

  local lib_path = blink_dir .. '/blink.lib'
  if vim.uv.fs_stat(lib_path) then
    goto blink_done  -- already present, nothing to do
  end

  -- 2. Detect OS / arch to pick the right release asset.
  local os_name  = jit.os:lower()   -- 'linux' | 'osx' | 'windows'
  local arch     = jit.arch:lower() -- 'x64' | 'arm64' | ...

  local platform
  if os_name == 'osx' then
    platform = (arch == 'arm64') and 'aarch64-apple-darwin.dylib'
                                  or  'x86_64-apple-darwin.dylib'
  elseif os_name == 'linux' then
    platform = (arch == 'arm64') and 'aarch64-unknown-linux-gnu.so'
                                  or  'x86_64-unknown-linux-gnu.so'
  else
    vim.notify('[bootstrap] blink.cmp: unsupported platform ' .. os_name .. '/' .. arch, vim.log.levels.WARN)
    goto blink_done
  end

  -- 3. Resolve the exact version from the installed plugin's git tag.
  local tag_result = vim.system(
    { 'git', '-C', blink_dir, 'describe', '--tags', '--abbrev=0' },
    { text = true }
  ):wait()
  local version = (tag_result.code == 0)
    and vim.trim(tag_result.stdout)
    or  nil

  if not version or version == '' then
    vim.notify('[bootstrap] blink.cmp: could not determine installed version (git describe failed)', vim.log.levels.WARN)
    goto blink_done
  end

  -- 4. Download.
  local url = ('https://github.com/Saghen/blink.cmp/releases/download/%s/%s'):format(version, platform)
  vim.notify('[bootstrap] Downloading blink.cmp native lib ' .. version .. ' (' .. platform .. ')…', vim.log.levels.INFO)

  local dl = vim.system({ 'curl', '-fsSL', url, '-o', lib_path }, { text = true }):wait()
  if dl.code ~= 0 then
    vim.notify('[bootstrap] blink.cmp download failed:\n' .. (dl.stderr or ''), vim.log.levels.ERROR)
  else
    vim.notify('[bootstrap] blink.cmp native lib installed.', vim.log.levels.INFO)
  end

  ::blink_done::
end
