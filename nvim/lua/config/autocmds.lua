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

-- Set filetype for template files based on their content or extension
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.zsh.tmpl',
  callback = function() vim.bo.filetype = 'zsh' end,
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.toml.tmpl',
  callback = function() vim.bo.filetype = 'toml' end,
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.yaml.tmpl',
  callback = function() vim.bo.filetype = 'yaml' end,
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.yaml.tmpl',
  callback = function() vim.bo.filetype = 'yaml' end,
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.json.tmpl',
  callback = function() vim.bo.filetype = 'json' end,
})
