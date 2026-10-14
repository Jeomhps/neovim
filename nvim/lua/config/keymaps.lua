-- [[ Keymaps ]]
-- Plugin-specific keymaps live next to their plugin spec (e.g. lua/plugins/snacks.lua).

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv",  { desc = 'Move line down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv",  { desc = 'Move line up' })
vim.keymap.set("n", "<C-d>", "<C-d>zz",        { desc = 'Scroll down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz",        { desc = 'Scroll up' })
vim.keymap.set("n", "n", "nzzzv",              { desc = 'Next search result' })
vim.keymap.set("n", "N", "Nzzzv",              { desc = 'Previous search result' })

vim.keymap.set("n", "<leader>b[", "<cmd>bprev<CR>",   { desc = 'Previous buffer' })
vim.keymap.set("n", "<leader>b]", "<cmd>bnext<CR>",   { desc = 'Next buffer' })
vim.keymap.set("n", "<leader>bl", "<cmd>b#<CR>",      { desc = 'Last buffer' })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = 'Delete buffer' })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = '[D]iagnostic [E]xpand' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set({"v", "x", "n"}, '<leader>y', '"+y',  { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({'n', 'v', 'x'}, '<leader>p', '"+p',  { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',           { noremap = true, silent = true, desc = 'Paste from clipboard (insert)' })
vim.keymap.set("x", "<leader>P", '"_dP',               { noremap = true, silent = true, desc = 'Paste over selection' })

-- Pin `uses: owner/action@v4` to its commit SHA (keeps a `# v4` comment) with pinact.
vim.keymap.set('n', '<leader>cp', function()
  local file = vim.api.nvim_buf_get_name(0)
  if not (file:find('/%.github/workflows/') or file:find('/%.github/actions/')) then
    return vim.notify('Not a GitHub Actions file', vim.log.levels.WARN)
  end
  if vim.fn.executable('pinact') ~= 1 then
    return vim.notify('pinact not found on PATH', vim.log.levels.ERROR)
  end
  vim.cmd.write()
  -- run from the repo root so pinact finds the project's .pinact.yaml (ignore_actions, ghes)
  local root = vim.fs.root(file, '.git') or vim.fs.dirname(file)
  vim.system({ 'pinact', 'run', file }, { text = true, cwd = root }, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      return vim.notify('pinact failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR)
    end
    vim.cmd.checktime() -- reload the buffer with the pinned shas
    vim.notify('Pinned actions to commit SHAs')
  end))
end, { desc = '[C]ode [P]in GitHub actions to SHA' })
