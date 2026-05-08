-- Snacks early setup — sourced directly from init.lua before lze.load so that
-- hooks (replace_netrw, statuscolumn, indent) are registered before VimEnter.
-- Keymaps are still registered lazily via the lze spec in plugins/snacks.lua.
require('snacks').setup({
  explorer = { replace_netrw = true },
  picker   = { sources = { explorer = { auto_close = true } } },
  git      = {},
  terminal = {},
  scope    = {},
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
