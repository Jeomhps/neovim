-- [[ Autocommands ]]

-- Disable auto-comment on new lines
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Briefly highlight yanked text
local yank_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group    = yank_group,
  pattern  = '*',
  callback = function() vim.highlight.on_yank() end,
})

-- Detect Typst files and set filetype
vim.api.nvim_create_autocmd({'BufReadPost', 'BufNewFile'}, {
  pattern = {'*.typ'},
  callback = function() vim.bo.filetype = 'typst' end,
  desc = 'Set filetype for Typst files',
})

-- Restore cursor to last known position on reopen
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor position',
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Trim trailing whitespace',
  pattern = '*',
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})
