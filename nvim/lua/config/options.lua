-- [[ Options ]]
vim.o.exrc    = false
vim.opt.list  = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.hlsearch   = true
vim.opt.inccommand = 'split'
vim.opt.scrolloff  = 10

vim.wo.number         = true
vim.wo.relativenumber = true
vim.wo.signcolumn     = 'yes'

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

local clipboard_mode = nixInfo("wsl", "settings", "clipboard")
if clipboard_mode == "wsl" then
  -- Explicitly force win32yank so neovim doesn't fall back to OSC 52,
  -- which doesn't work reliably on WSL when the terminal is unrecognised.
  vim.g.clipboard = {
    name = 'win32yank',
    copy  = { ['+'] = { 'win32yank', '-i', '--crlf' }, ['*'] = { 'win32yank', '-i', '--crlf' } },
    paste = { ['+'] = { 'win32yank', '-o', '--lf' },  ['*'] = { 'win32yank', '-o', '--lf' } },
    cache_enabled = 0,
  }
  vim.opt.clipboard = 'unnamedplus'
elseif clipboard_mode == "system" then
  -- macOS / Linux with a native clipboard tool (pbcopy, xclip, wl-clipboard…)
  -- Neovim's auto-detection is reliable here, just enable unnamedplus.
  vim.opt.clipboard = 'unnamedplus'
  -- "none" → leave everything untouched
end

vim.g.netrw_liststyle = 0
vim.g.netrw_banner    = 0

-- ── Colorscheme ───────────────────────────────────────────────────────────────
-- catppuccin-nvim is a start plugin (always in rtp) so this is safe here:
-- synchronous, no VimEnter, no vim.schedule → zero flash.
vim.cmd.colorscheme("catppuccin-" .. nixInfo("mocha", "settings", "colorscheme"))
