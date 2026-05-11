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
