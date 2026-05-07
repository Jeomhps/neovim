return {
  {
    "snacks.nvim",
    auto_enable = true,
    lazy = false,
    priority = 1000,
    after = function(_)
      -- snacks is a start plugin so its own plugin/ files (incl. netrw disable)
      -- are already sourced. Deferring setup() here pushes the expensive feature
      -- initialisation (indent guides, statuscolumn, scope …) to after startup.
      vim.schedule(function()
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

      -- Remote-command helper used by the lazygit editAtLine / edit configs above
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

      vim.keymap.set("n", "-",          function() Snacks.explorer.open() end,  { desc = 'File explorer' })
      vim.keymap.set("n", "<c-\\>",     function() Snacks.terminal.open() end,  { desc = 'Terminal' })
      vim.keymap.set("n", "<leader>_",  function() Snacks.lazygit.open() end,   { desc = 'LazyGit' })
      vim.keymap.set('n', "<leader>sf", function() Snacks.picker.smart() end,   { desc = "Smart find files" })
      vim.keymap.set('n', "<leader><leader>s", function() Snacks.picker.buffers() end, { desc = "Search buffers" })
      vim.keymap.set('n', "<leader>ff", function() Snacks.picker.files() end,         { desc = "Find files" })
      vim.keymap.set('n', "<leader>fg", function() Snacks.picker.git_files() end,     { desc = "Find git files" })
      vim.keymap.set('n', "<leader>sb", function() Snacks.picker.lines() end,         { desc = "Buffer lines" })
      vim.keymap.set('n', "<leader>sB", function() Snacks.picker.grep_buffers() end,  { desc = "Grep open buffers" })
      vim.keymap.set('n', "<leader>sg", function() Snacks.picker.grep() end,          { desc = "Grep" })
      vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Grep word" })
      vim.keymap.set('n', "<leader>sd", function() Snacks.picker.diagnostics() end,        { desc = "Diagnostics" })
      vim.keymap.set('n', "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer diagnostics" })
      vim.keymap.set('n', "<leader>sh", function() Snacks.picker.help() end,    { desc = "Help pages" })
      vim.keymap.set('n', "<leader>sj", function() Snacks.picker.jumps() end,   { desc = "Jumps" })
      vim.keymap.set('n', "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
      vim.keymap.set('n', "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location list" })
      vim.keymap.set('n', "<leader>sm", function() Snacks.picker.marks() end,   { desc = "Marks" })
      vim.keymap.set('n', "<leader>sM", function() Snacks.picker.man() end,     { desc = "Man pages" })
      vim.keymap.set('n', "<leader>sq", function() Snacks.picker.qflist() end,  { desc = "Quickfix list" })
      vim.keymap.set('n', "<leader>sR", function() Snacks.picker.resume() end,  { desc = "Resume" })
      vim.keymap.set('n', "<leader>su", function() Snacks.picker.undo() end,    { desc = "Undo history" })
      end) -- end vim.schedule
    end,
  },
}
