-- Snacks early setup — sourced directly from init.lua before lze.load so that
-- hooks (replace_netrw, statuscolumn, indent) are registered before VimEnter.
-- Keymaps are still registered lazily via the lze spec in plugins/snacks.lua.
require('snacks').setup({
  explorer = { replace_netrw = true },
  picker   = { sources = { explorer = { auto_close = true } } },
  git      = {},
  terminal = {},
  scope    = {},
  notifier = {},
  zen      = {},
  dashboard = {
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File",       action = function() Snacks.picker.files({ hidden = true }) end },
        { icon = " ", key = "n", desc = "New File",         action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text",        action = function() Snacks.picker.grep() end },
        { icon = " ", key = "r", desc = "Recent Files",     action = function() Snacks.picker.recent() end },
        { icon = " ", key = "c", desc = "Config",           action = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
        { icon = " ", key = "s", desc = "Restore Session",  section = "session" },
        { icon = " ", key = "q", desc = "Quit",             action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { section = "startup" },
    },
  },
  indent   = {
    scope = { hl = 'SnacksIndent' },
    chunk = { hl = 'SnacksIndent' },
  },
  statuscolumn = {
    left  = { "mark", "git" },
    right = { "sign", "fold" },
    folds = { open = false, git_hl = false },
    git   = { patterns = { "GitSign", "MiniDiffSign" } },
    refresh = 50,
  },
  lazygit = {
    config = {
      os = {
        editPreset      = "nvim-remote",
        edit            = vim.v.progpath .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}})<CR>']=],
        editAtLine      = vim.v.progpath .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}}, {{line}})<CR>']=],
        openDirInEditor = vim.v.progpath .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{dir}})<CR>']=],
        editAtLineAndWait = nixInfo(vim.v.progpath, "progpath") .. " +{{line}} {{filename}}",
      },
    },
  },
})

-- Remote-command helper used by the lazygit editAtLine / edit configs above.
nixInfo.lazygit_fix = function(path, line)
  local prev     = vim.fn.bufnr("#")
  local prev_win = vim.fn.bufwinid(prev)
  vim.api.nvim_feedkeys("q", "n", false)
  vim.api.nvim_buf_call(prev, function()
    vim.cmd.edit(path)
    local buf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      if buf then
        vim.api.nvim_win_set_buf(prev_win, buf)
        if line then vim.api.nvim_win_set_cursor(0, { line, 0 }) end
      end
    end)
  end)
end
