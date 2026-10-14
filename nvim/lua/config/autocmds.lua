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
  callback = function() vim.hl.on_yank() end,
})

-- Filetypes for devops files neovim doesn't detect on its own. Compound names
-- (yaml.*) keep yaml tooling working while letting servers target the subtype.
-- Only treat templates/ as helm when inside a chart (CloudFormation etc. also use that dir).
local function helm_chart(path)
  if vim.fs.find('Chart.yaml', { upward = true, path = vim.fs.dirname(path) })[1] then
    return 'helm'
  end
end

vim.filetype.add({
  extension = { tfvars = 'terraform-vars' },
  filename = {
    ['.gitlab-ci.yml'] = 'yaml.gitlab',
    ['.gitlab-ci.yaml'] = 'yaml.gitlab',
    ['playbook.yml'] = 'yaml.ansible',
    ['playbook.yaml'] = 'yaml.ansible',
    ['site.yml'] = 'yaml.ansible',
    ['site.yaml'] = 'yaml.ansible',
  },
  pattern = {
    ['.*/templates/.*%.ya?ml'] = helm_chart,
    ['.*/templates/.*%.tpl'] = helm_chart,
    ['.*/helmfile.*%.ya?ml'] = 'helm',
    ['.*/playbooks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/handlers/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/docker%-compose[^/]*%.ya?ml'] = 'yaml.docker-compose',
    ['.*/compose[^/]*%.ya?ml'] = 'yaml.docker-compose',
  },
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
    -- Markdown uses trailing double-space as a hard line break; diffs/binaries must stay byte-exact.
    if vim.bo.binary or vim.tbl_contains({ 'markdown', 'diff' }, vim.bo.filetype) then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
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
