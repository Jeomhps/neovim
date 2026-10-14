return {
  {
    "snacks.nvim",
    auto_enable = true,
    -- Setup is called early in init.lua (config/snacks.lua) before VimEnter.
    -- lazy = false here ensures this after callback (keymaps) still fires via lze.
    lazy = false,
    after = function(_)
      vim.keymap.set("n", "-",          function() Snacks.explorer.open() end,  { desc = 'File explorer' })
      vim.keymap.set("n", "<leader>e",  function() Snacks.explorer.open() end,  { desc = 'File explorer' })
      vim.keymap.set("n", "<c-\\>",     function() Snacks.terminal.open() end,  { desc = 'Terminal' })
      vim.keymap.set("n", "<leader>z",  function() Snacks.zen() end,            { desc = 'Toggle Zen mode' })
      vim.keymap.set("n", "<leader>gg",  function() Snacks.lazygit.open() end,   { desc = 'LazyGit' })
      -- { lhs, picker, desc, picker opts, modes }
      local pickers = {
        { "<leader>sf",       "smart",              "Smart find files" },
        { "<leader><leader>", "buffers",            "Search buffers" },
        { "<leader>ff",       "files",              "Find files", { hidden = true } },
        { "<leader>fg",       "git_files",          "Find git files" },
        { "<leader>sb",       "lines",              "Buffer lines" },
        { "<leader>sB",       "grep_buffers",       "Grep open buffers" },
        { "<leader>sg",       "grep",               "Grep" },
        { "<leader>sw",       "grep_word",          "Grep word", nil, { "n", "x" } },
        { "<leader>sd",       "diagnostics",        "Diagnostics" },
        { "<leader>sD",       "diagnostics_buffer", "Buffer diagnostics" },
        { "<leader>sh",       "help",               "Help pages" },
        { "<leader>sj",       "jumps",              "Jumps" },
        { "<leader>sk",       "keymaps",            "Keymaps" },
        { "<leader>sl",       "loclist",            "Location list" },
        { "<leader>sm",       "marks",              "Marks" },
        { "<leader>sM",       "man",                "Man pages" },
        { "<leader>sq",       "qflist",             "Quickfix list" },
        { "<leader>sR",       "resume",             "Resume" },
        { "<leader>su",       "undo",               "Undo history" },
      }
      for _, p in ipairs(pickers) do
        vim.keymap.set(p[5] or "n", p[1], function() Snacks.picker[p[2]](p[4]) end, { desc = p[3] })
      end
      vim.keymap.set("n", "<leader>sn", function() Snacks.notifier.show_history() end, { desc = "Notification history" })

      -- ── Toggles ──────────────────────────────────────────────────────────
      Snacks.toggle.option("spell",         { name = "Spelling" }):map("<leader>ts")
      Snacks.toggle.option("wrap",          { name = "Wrap" }):map("<leader>tw")
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tn")
      Snacks.toggle.diagnostics():map("<leader>td")
      Snacks.toggle.inlay_hints():map("<leader>ti")
      Snacks.toggle.new({
        name = "Autoformat",
        get  = function() return vim.g.autoformat ~= false end,
        set  = function(state) vim.g.autoformat = state end,
      }):map("<leader>tf")
    end,
  },
}
