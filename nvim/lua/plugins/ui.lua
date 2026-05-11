return {
  {
    "mini.nvim",
    auto_enable = true,
    lazy = false,
    priority = 900,
    after = function(_) require('mini.icons').setup() end,
  },

  {
    "fidget.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_) require('fidget').setup({}) end,
  },

  {
    "lualine.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require('lualine').setup({
        options = {
          icons_enabled        = false,
          theme                = "auto",
          component_separators = '|',
          section_separators   = '',
        },
        sections = {
          lualine_c = { { 'filename', path = 1, status = true } },
        },
        inactive_sections = {
          lualine_b = { { 'filename', path = 3, status = true } },
          lualine_x = { 'filetype' },
        },
        tabline = {
          lualine_a = { 'buffers' },
          lualine_z = { 'tabs' },
        },
      })
    end,
  },

  {
    "gitsigns.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require('gitsigns').setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts        = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = 'Next hunk' })
          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = 'Previous hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'Stage hunk' })
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'Reset hunk' })
          map('n', '<leader>gs',  gs.stage_hunk,      { desc = 'Stage hunk' })
          map('n', '<leader>gr',  gs.reset_hunk,      { desc = 'Reset hunk' })
          map('n', '<leader>gS',  gs.stage_buffer,    { desc = 'Stage buffer' })
          map('n', '<leader>gu',  gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
          map('n', '<leader>gR',  gs.reset_buffer,    { desc = 'Reset buffer' })
          map('n', '<leader>gp',  gs.preview_hunk,    { desc = 'Preview hunk' })
          map('n', '<leader>gb',  function() gs.blame_line { full = false } end, { desc = 'Blame line' })
          map('n', '<leader>gd',  gs.diffthis,        { desc = 'Diff index' })
          map('n', '<leader>gD',  function() gs.diffthis '~' end, { desc = 'Diff last commit' })
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'Toggle blame' })
          map('n', '<leader>gtd', gs.toggle_deleted,            { desc = 'Toggle deleted' })
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
        end,
      })
    end,
  },

  {
    "which-key.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require('which-key').setup({})
      require('which-key').add {
        { "<leader><leader>", group = "buffer" },
        { "<leader>c",  group = "[c]ode" },
        { "<leader>d",  group = "[d]ocument" },
        { "<leader>g",  group = "[g]it" },
        { "<leader>r",  group = "[r]ename" },
        { "<leader>s",  group = "[s]earch" },
        { "<leader>t",  group = "[t]oggles" },
        { "<leader>w",  group = "[w]orkspace" },
      }
    end,
  },

  {
    "rainbow-delimiters.nvim",
    auto_enable = true,
    event = "BufReadPre",
    after = function(_)
      local rainbow_delimiters = require('rainbow-delimiters')
      require('rainbow-delimiters.setup').setup({})
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          rainbow_delimiters.enable(args.buf)
        end,
      })
    end,
  },

  {
    "typst-preview.nvim",
    auto_enable = true,
    -- Load for typst files; can also set lazy = false to always load
    ft = "typst",
    after = function(_)
      -- typst-preview sets itself up on require; call setup and explicitly
      -- point it at the tinymist binary Neovim has on its PATH.
      local ok, mod = pcall(require, 'typst-preview')
      if ok and type(mod.setup) == 'function' then
        mod.setup({ dependencies_bin = { tinymist = 'tinymist' } })
      end
    end,
  },
}
