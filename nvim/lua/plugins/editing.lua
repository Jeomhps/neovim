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
          lua       = nixInfo(nil, "settings", "cats", "lua") and { "stylua" } or nil,
          sh        = nixInfo(nil, "settings", "cats", "bash") and { "shfmt" } or nil,
          terraform = nixInfo(nil, "settings", "cats", "terraform") and { "terraform_fmt" } or nil,
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
}
