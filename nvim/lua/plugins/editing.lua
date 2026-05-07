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
        },
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
        -- add linters here, e.g.: javascript = { 'eslint' },
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
}
