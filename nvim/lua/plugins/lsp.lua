return {
  -- ── lspconfig (base + on_attach keymaps) ─────────────────────────────────
  {
    "nvim-lspconfig",
    auto_enable = true,
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = function(_, bufnr)
          local nmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end
          nmap('<leader>rn', vim.lsp.buf.rename,          '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action,     '[C]ode [A]ction')
          nmap('gd',         vim.lsp.buf.definition,      '[G]oto [D]efinition')
          nmap('<leader>D',  vim.lsp.buf.type_definition, 'Type [D]efinition')
          nmap('gr',  function() Snacks.picker.lsp_references() end,            '[G]oto [R]eferences')
          nmap('gI',  function() Snacks.picker.lsp_implementations() end,       '[G]oto [I]mplementation')
          nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end,        '[D]ocument [S]ymbols')
          nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')
          nmap('K',     vim.lsp.buf.hover,          'Hover Documentation')
          nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
          nmap('gD',         vim.lsp.buf.declaration,             '[G]oto [D]eclaration')
          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder,    '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')
          vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })
        end,
      })
    end,
  },

  -- ── Mason (non-nix fallback) ──────────────────────────────────────────
  {
    "mason.nvim",
    enabled   = not nixInfo.isNix,
    priority  = 100,
    on_plugin = { "nvim-lspconfig" },
    after = function(_)
      require('mason').setup()
    end,
    lsp = function(plugin)
      local pkg_name = plugin.mason or plugin.name
      local ok, registry = pcall(require, 'mason-registry')
      if not ok then return end
      registry.refresh(function()
        local ok2, pkg = pcall(registry.get_package, pkg_name)
        if ok2 and not pkg:is_installed() then
          pkg:install()
        end
      end)
    end,
  },

  -- ── lazydev (Lua LSP extras + nixInfo annotations) ────────────────────────
  {
    "lazydev.nvim",
    auto_enable = true,
    cmd = { "LazyDev" },
    ft  = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "nixInfo%.lze" }, path = nixInfo("lze",      "plugins", "start", "lze")      .. '/lua' },
          { words = { "nixInfo%.lze" }, path = nixInfo("lzextras", "plugins", "start", "lzextras") .. '/lua' },
        },
      })
    end,
  },

  -- ── LSP servers ───────────────────────────────────────────────────────────
  {
    "lua_ls",
    for_cat = "lua",
    mason   = "lua-language-server",
    lsp = {
      filetypes = { 'lua' },
      settings  = {
        Lua = {
          signatureHelp = { enabled = true },
          diagnostics   = {
            globals = { "nixInfo", "vim" },
            disable = { 'missing-fields' },
          },
        },
      },
    },
  },
  {
    "nixd",
    enabled = nixInfo.isNix,
    for_cat = "nix",
    lsp = {
      filetypes = { "nix" },
      settings  = {
        nixd = {
          nixpkgs    = { expr = [[import <nixpkgs> {}]] },
          formatting = { command = { "nixfmt" } },
          diagnostic = { suppress = { "sema-escaping-with" } },
        },
      },
    },
  },
}
