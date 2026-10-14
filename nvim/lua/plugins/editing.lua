return {
  {
    "conform.nvim",
    auto_enable = true,
    keys = { { "<leader>FF", desc = "[F]ormat [F]ile" } },
    after = function(_)
      local conform = require("conform")

      -- Formatters are gated on the binary being on PATH rather than on Nix
      -- cats, so Nix and non-Nix behave the same (conform has no Mason
      -- fallback; on non-Nix install the tools manually, see :checkhealth config).
      local bin = { terraform_fmt = "terraform", tofu_fmt = "tofu", ruff_format = "ruff" }
      local function available(by_ft)
        local out = {}
        for ft, list in pairs(by_ft) do
          local keep = { stop_after_first = list.stop_after_first }
          for _, name in ipairs(list) do
            if vim.fn.executable(bin[name] or name) == 1 then keep[#keep + 1] = name end
          end
          if #keep > 0 then out[ft] = keep end
        end
        return out
      end

      local tf = { "terraform_fmt", "tofu_fmt", stop_after_first = true }
      conform.setup({
        formatters_by_ft = available({
          lua                = { "stylua" },
          sh                 = { "shfmt" },
          bash               = { "shfmt" },
          nix                = { "nixfmt" },
          go                 = { "gofmt" },
          c                  = { "clang-format" },
          cpp                = { "clang-format" },
          python             = { "ruff_format" },
          yaml               = { "yamlfmt" },
          json               = { "jq" },
          terraform          = tf,
          ["terraform-vars"] = tf,
          hcl                = tf,
        }),
        format_on_save = function(_)
          if vim.g.autoformat == false then return end
          return { timeout_ms = 1000, lsp_format = "fallback" }
        end,
      })
      vim.keymap.set({ "n", "v" }, "<leader>FF", function()
        conform.format({ lsp_format = "fallback", async = false, timeout_ms = 1000 })
      end, { desc = "[F]ormat [F]ile" })
    end,
  },

  {
    "nvim-lint",
    auto_enable = true,
    event = "FileType",
    after = function(_)
      local lint = require('lint')
      lint.linters_by_ft = {
        lua              = { 'selene' },
        nix              = { 'statix' },
        sh               = { 'shellcheck' },
        bash             = { 'shellcheck' },
        dockerfile       = { 'hadolint' },
        yaml             = { 'yamllint' },
        ['yaml.ansible'] = { 'ansible_lint' },
        terraform        = { 'tflint' },
        markdown         = { 'markdownlint' },
      }
      local function run()
        local names = vim.list_slice(lint.linters_by_ft[vim.bo.filetype] or {})
        -- GitHub Actions workflows are plain yaml; only lint those with actionlint.
        if vim.fn.expand('%:p'):find('/%.github/workflows/') then
          names[#names + 1] = 'actionlint'
        end
        -- Skip linters that aren't installed (nvim-lint throws on a missing binary).
        names = vim.tbl_filter(function(name)
          local l = lint.linters[name]
          local cmd = type(l) == 'table' and l.cmd or nil
          if type(cmd) == 'function' then cmd = cmd() end
          return cmd == nil or vim.fn.executable(cmd) == 1
        end, names)
        if #names > 0 then lint.try_lint(names) end
      end
      vim.api.nvim_create_autocmd({ "BufWritePost" }, { callback = run })
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

  {
    -- oil.nvim: used for remote hosts only (oil-ssh://user@host//path).
    -- Locally Snacks.explorer stays the file explorer, so oil must not hijack
    -- directory buffers (default_file_explorer = false).
    "oil.nvim",
    auto_enable = true,
    cmd   = { "Oil" },
    event = {
      { event = "BufReadCmd",  pattern = "oil-ssh://*" },
      { event = "BufReadCmd",  pattern = "oil-ssh-sudo://*" },
    },
    after = function(_)
      require("oil").setup({
        default_file_explorer = false,
        skip_confirm_for_simple_edits = true,
        keymaps = { ["q"] = "actions.close" },
      })
    end,
  },
}
