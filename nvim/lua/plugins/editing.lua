return {
  {
    "conform.nvim",
    auto_enable = true,
    keys = { { "<leader>FF", desc = "[F]ormat [F]ile" } },
    after = function(_)
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          -- add formatters here, e.g.: go = { "gofmt" },
          lua = nixInfo(nil, "settings", "cats", "lua") and { "stylua" } or nil,
          sh  = nixInfo(nil, "settings", "cats", "bash") and { "shfmt" } or nil,
        },
        format_on_save = function(_)
          if vim.g.autoformat == false then return end
          return { timeout_ms = 1000, lsp_fallback = true }
        end,
      })
      vim.keymap.set({ "n", "v" }, "<leader>FF", function()
        conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
      end, { desc = "[F]ormat [F]ile" })
    end,
  },

  {
    "nvim-lint",
    auto_enable = true,
    event = "FileType",
    after = function(_)
      require('lint').linters_by_ft = {
        lua        = { 'selene' },
        nix        = { 'statix' },
        sh         = { 'shellcheck' },
        dockerfile = { 'hadolint' },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  {
    "nvim-surround",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_) require('nvim-surround').setup() end,
  },

  {
    "vim-startuptime",
    auto_enable = true,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries       = 10
      vim.g.startuptime_exe_path    = nixInfo(vim.v.progpath, "progpath")
    end,
  },

  {
    "persistence.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require('persistence').setup()
      vim.keymap.set('n', '<leader>Ss', function() require('persistence').load() end,             { desc = '[S]ession restore (cwd)' })
      vim.keymap.set('n', '<leader>SS', function() require('persistence').select() end,            { desc = '[S]ession select' })
      vim.keymap.set('n', '<leader>Sl', function() require('persistence').load({ last = true }) end, { desc = '[S]ession restore last' })
      vim.keymap.set('n', '<leader>Sd', function() require('persistence').stop() end,               { desc = "[S]ession don't save" })
    end,
  },

  {
    "grug-far.nvim",
    auto_enable = true,
    keys = { { "<leader>sr", desc = "Search and Replace" } },
    after = function(_)
      require("grug-far").setup({
        keymaps = { close = { n = "q" } },
      })
      vim.keymap.set("n", "<leader>sr", function() require("grug-far").open() end, { desc = "Search and Replace" })
    end,
  },

  {
    -- flash.nvim: jump to any visible location in a few keystrokes.
    -- "S" is intentionally left unmapped in visual mode so it doesn't
    -- collide with nvim-surround's visual-mode "add surround" keymap.
    "flash.nvim",
    auto_enable = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Flash" },
      { "S", mode = { "n", "o" },      desc = "Flash Treesitter" },
      { "r", mode = "o",               desc = "Remote Flash" },
      { "R", mode = { "o", "x" },      desc = "Treesitter Search" },
    },
    after = function(_)
      vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end,               { desc = "Flash" })
      vim.keymap.set({ "n", "o" },      "S", function() require("flash").treesitter() end,          { desc = "Flash Treesitter" })
      vim.keymap.set("o",               "r", function() require("flash").remote() end,              { desc = "Remote Flash" })
      vim.keymap.set({ "o", "x" },      "R", function() require("flash").treesitter_search() end,   { desc = "Treesitter Search" })
      vim.keymap.set("c", "<C-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })
    end,
  },

  {
    "todo-comments.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      local todo = require("todo-comments")
      todo.setup({})
      vim.keymap.set("n", "]t", function() todo.jump_next() end, { desc = "Next Todo Comment" })
      vim.keymap.set("n", "[t", function() todo.jump_prev() end, { desc = "Previous Todo Comment" })
      vim.keymap.set("n", "<leader>st", "<cmd>TodoQuickFix<CR>", { desc = "Search Todo Comments" })
    end,
  },
}
