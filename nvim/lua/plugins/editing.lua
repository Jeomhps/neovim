-- GitHub Actions workflows are yaml but follow different conventions (no `---`,
-- `on:` key), so linting/formatting treats them separately.
local function is_workflow(path)
  return path:find('/%.github/workflows/') ~= nil
end

return {
  {
    "conform.nvim",
    auto_enable = true,
    event = "BufWritePre", -- format_on_save is configured in setup, so load before the first save
    keys = {
      {
        "<leader>FF",
        function() require("conform").format({ lsp_format = "fallback", async = false, timeout_ms = 1000 }) end,
        mode = { "n", "v" },
        desc = "[F]ormat [F]ile",
      },
    },
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
        formatters = {
          -- Match yamllint's defaults (document-start, 2 spaces before comments); out of the
          -- box yamlfmt strips the leading `---` and pads comments with 1 space.
          -- Workflows are the exception: nobody starts those with `---`.
          yamlfmt = {
            prepend_args = function(_, ctx)
              local opts = "pad_line_comments=2,retain_line_breaks=true"
              if not is_workflow(ctx.filename) then opts = "include_document_start=true," .. opts end
              return { "-formatter", opts }
            end,
          },
        },
        format_on_save = function(_)
          if vim.g.autoformat == false then return end
          return { timeout_ms = 1000, lsp_format = "fallback" }
        end,
      })
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
        ansible          = { 'ansible_lint' },
        terraform        = { 'tflint' },
        markdown         = { 'markdownlint' },
      }
      -- yamllint's defaults flag normal workflow style (`on:` truthy, no `---`, long lines).
      lint.linters.yamllint_workflow = vim.tbl_extend('force', lint.linters.yamllint, {
        args = {
          '-d', '{extends: default, rules: {document-start: disable, line-length: disable, truthy: {check-keys: false}}}',
          '--format', 'parsable', '-',
        },
      })
      local function run()
        -- Compound filetypes (yaml.ansible, yaml.docker-compose) get each part's linters.
        local names = {}
        for _, ft in ipairs(vim.split(vim.bo.filetype, '.', { plain = true })) do
          vim.list_extend(names, lint.linters_by_ft[ft] or {})
        end
        if is_workflow(vim.fn.expand('%:p')) then
          names = { 'yamllint_workflow', 'actionlint', 'zizmor' }
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
      -- Lint on open and on leaving insert too, not just on save. Disk-reading linters
      -- (yamllint, tflint, ...) still only see saved content; stdin ones see the buffer.
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, { callback = run })
      run() -- the buffer that triggered FileType is already loaded
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
    keys = { { "<leader>sr", function() require("grug-far").open() end, desc = "Search and Replace" } },
    after = function(_)
      require("grug-far").setup({
        keymaps = { close = { n = "q" } },
      })
    end,
  },

  {
    -- flash.nvim: jump to any visible location in a few keystrokes.
    -- "S" is intentionally left unmapped in visual mode so it doesn't
    -- collide with nvim-surround's visual-mode "add surround" keymap.
    "flash.nvim",
    auto_enable = true,
    keys = {
      { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash" },
      { "S",     function() require("flash").treesitter() end,        mode = { "n", "o" },      desc = "Flash Treesitter" },
      { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote Flash" },
      { "R",     function() require("flash").treesitter_search() end, mode = { "o", "x" },      desc = "Treesitter Search" },
    },
    after = function(_)
      require("flash").setup()
      -- cmdline-mode maps aren't lazy-loaded by lze, so set this one here
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
