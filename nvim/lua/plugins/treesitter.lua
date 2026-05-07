return {
  {
    "nvim-treesitter",
    -- BufReadPre fires before FileType, so the FileType autocmd registered in
    -- `after` is in place by the time FileType fires for that same buffer.
    event = "BufReadPre",
    auto_enable = true,
    after = function(_)
      local function try_attach(buf, language)
        if not vim.treesitter.language.add(language) then return false end
        vim.treesitter.start(buf, language)
        vim.wo.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        vim.o.foldlevel   = 99
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        return true
      end
      local installable = require("nvim-treesitter").get_available()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)
          if not language then return end
          if not try_attach(args.buf, language) then
            if vim.tbl_contains(installable, language) then
              require("nvim-treesitter").install(language):await(function()
                try_attach(args.buf, language)
              end)
            end
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter-textobjects",
    auto_enable = true,
    dep_of = { "nvim-treesitter" }, -- load alongside treesitter, not at startup
    before = function(_) vim.g.no_plugin_maps = true end,
    after  = function(_)
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer']  = 'V',
          },
          include_surrounding_whitespace = false,
        },
      }
      local sel = require "nvim-treesitter-textobjects.select"
      vim.keymap.set({ "x", "o" }, "am", function() sel.select_textobject("@function.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "im", function() sel.select_textobject("@function.inner", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ac", function() sel.select_textobject("@class.outer",    "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ic", function() sel.select_textobject("@class.inner",    "textobjects") end)
      vim.keymap.set({ "x", "o" }, "as", function() sel.select_textobject("@local.scope",    "locals")      end)
    end,
  },
}
