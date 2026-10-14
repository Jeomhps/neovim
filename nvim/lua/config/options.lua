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

-- ── WSL: put the slow Windows /mnt dirs last on PATH ─────────────────────────
-- Each lookup of a tool by name (nvim-lint, conform, LSP spawns) scans PATH, and
-- the /mnt/* entries are on a slow 9p mount: ~100 ms per lookup, since the Nix
-- wrapper appends its tools after them. Windows exes (clip.exe, ...) still resolve.
if vim.fn.has("wsl") == 1 then
  local native, windows = {}, {}
  for dir in vim.env.PATH:gmatch("[^:]+") do
    table.insert(dir:find("^/mnt/") and windows or native, dir)
  end
  vim.env.PATH = table.concat(vim.list_extend(native, windows), ":")
end

vim.o.list      = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.inccommand = 'split'
vim.o.scrolloff  = 10

-- vim.o (:set) rather than vim.wo so every window inherits these, not just the first
vim.o.number         = true
vim.o.relativenumber = true
vim.o.signcolumn     = 'yes'
vim.o.cursorline     = true

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

-- ── Winbar (nvim-navic breadcrumbs) ──────────────────────────────────────────
-- Defined here (not in the plugin spec) since winbar is redrawn constantly and
-- must stay safe even before nvim-navic has loaded or attached to any client.
_G.NavicWinbar = function()
  local ok, navic = pcall(require, 'nvim-navic')
  if ok and navic.is_available() then
    return navic.get_location()
  end
  return ''
end
vim.o.winbar = "%{%v:lua.NavicWinbar()%}"

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
