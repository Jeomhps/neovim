-- [[ Options ]]

-- ── Disable unused built-in runtime plugins ──────────────────────────────────
-- netrw is fully replaced by Snacks.explorer (replace_netrw = true); the rest
-- are rarely-used built-ins (archive editing, tutor, spellfile) — skipping
-- their plugin/*.vim sourcing shaves a few ms off every startup.
vim.g.loaded_netrwPlugin      = 1
vim.g.loaded_netrw            = 1
vim.g.loaded_gzip             = 1
vim.g.loaded_zip              = 1
vim.g.loaded_zipPlugin        = 1
vim.g.loaded_tar              = 1
vim.g.loaded_tarPlugin        = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_spellfile_plugin = 1

vim.o.exrc    = false
vim.opt.list  = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.hlsearch   = true
vim.opt.inccommand = 'split'
vim.opt.scrolloff  = 10

vim.wo.number         = true
vim.wo.relativenumber = true
vim.wo.signcolumn     = 'yes'
vim.wo.cursorline     = true

vim.o.winborder = 'rounded'

vim.o.mouse       = 'a'
vim.o.expandtab   = true
vim.opt.cpoptions:append('I')
vim.o.breakindent = true
vim.o.undofile    = true
vim.o.ignorecase  = true
vim.o.smartcase   = true
vim.o.updatetime  = 250
vim.o.timeoutlen  = 300
vim.o.completeopt = 'menu,preview,noselect'
vim.o.termguicolors = true

local clipboard_mode = nixInfo("system", "settings", "clipboard")
if clipboard_mode == "wsl" then
  -- Use Windows built-ins exposed via WSL interop.
  -- clip.exe   → writes (always fast, built-in)
  -- wsl-paste  → reads: uses win32yank.exe if installed on the Windows host
  --              (scoop install win32yank / winget install equalsraf.win32yank),
  --              otherwise falls back to powershell.exe Get-Clipboard (~300-700 ms).
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy  = { ['+'] = 'clip.exe', ['*'] = 'clip.exe' },
    paste = { ['+'] = { 'wsl-paste' }, ['*'] = { 'wsl-paste' } },
    cache_enabled = 0,
  }
  vim.opt.clipboard = 'unnamedplus'
elseif clipboard_mode == "system" then
  -- macOS / Linux with a native clipboard tool (pbcopy, xclip, wl-clipboard…)
  -- Neovim's auto-detection is reliable here, just enable unnamedplus.
  vim.opt.clipboard = 'unnamedplus'
  -- "none" → leave everything untouched
end

-- ── Diagnostics ───────────────────────────────────────────────────────────────
vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
    },
  },
})

-- ── Colorscheme ───────────────────────────────────────────────────────────────
-- catppuccin-nvim is a start plugin (always in rtp) so this is safe here:
-- synchronous, no VimEnter, no vim.schedule → zero flash.
vim.cmd.colorscheme("catppuccin-" .. nixInfo("mocha", "settings", "colorscheme"))
