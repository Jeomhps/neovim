vim.loader.enable() -- bytecode caching

-- ── nixInfo bootstrap (also handles non-nix) ─────────────────────────────────
do
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function(_, default) return default end
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  end
end

-- ── lze handler registration ──────────────────────────────────────────────────
nixInfo.lze.register_handlers {
  {
    -- auto_enable = true  → disable if plugin not installed by nix
    -- auto_enable = "name" → disable if that name is not installed
    -- auto_enable = { "a", "b" } → disable if any are missing
    spec_field = "auto_enable",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.auto_enable) == "table" then
          for _, name in pairs(plugin.auto_enable) do
            if not nixInfo.get_nix_plugin_path(name) then
              plugin.enabled = false
              break
            end
          end
        elseif type(plugin.auto_enable) == "string" then
          if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then
            plugin.enabled = false
          end
        elseif type(plugin.auto_enable) == "boolean" and plugin.auto_enable then
          if not nixInfo.get_nix_plugin_path(plugin.name) then
            plugin.enabled = false
          end
        end
      end
      return plugin
    end,
  },
  {
    -- for_cat = "name" → disable if that top-level nix spec is not enabled
    spec_field = "for_cat",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.for_cat) == "string" then
          plugin.enabled = nixInfo(false, "settings", "cats", plugin.for_cat)
        end
      end
      return plugin
    end,
  },
  nixInfo.lze.lsp,
}

-- Performant filetype fallback for the lsp handler
-- https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_nix_plugin_path "nvim-lspconfig"
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    return (ok and cfg or {}).filetypes or {}
  else
    return (vim.lsp.config[name] or {}).filetypes or {}
  end
end)

-- leader must be set before any plugin keymaps are registered
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- ── core config ───────────────────────────────────────────────────────────────
require("config.options")   -- vim options + synchronous colorscheme (no flash)
require("config.keymaps")   -- base keymaps (no plugin dependencies)
require("config.autocmds")  -- autocommands

-- ── plugin specs (each file returns a table of lze specs) ─────────────────────
nixInfo.lze.load {
  { import = "plugins.snacks"     },
  { import = "plugins.lsp"        },
  { import = "plugins.treesitter" },
  { import = "plugins.completion" },
  { import = "plugins.ui"         },
  { import = "plugins.editing"    },
}
