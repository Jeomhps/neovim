vim.loader.enable() -- bytecode caching

-- ── Non-Nix plugin bootstrap ─────────────────────────────────────────────────
-- Must run before the nixInfo block because that block calls require('lze').
-- On Nix, vim.g.nix_info_plugin_name is set by the wrapper — skip entirely.
if not vim.g.nix_info_plugin_name then
  require('bootstrap')
  -- On a fresh install vim.pack.add downloads plugins asynchronously.
  -- lze won't be in rtp yet; tell the user to restart and bail out early.
  if not pcall(require, 'lze') then
    vim.notify(
      '[bootstrap] Plugins installed – please restart Neovim.',
      vim.log.levels.WARN
    )
    return
  end
end

-- ── nixInfo bootstrap (also handles non-nix) ─────────────────────────────────
do
  local plugin_name = vim.g.nix_info_plugin_name
  local ok
  ok, _G.nixInfo = plugin_name and pcall(require, plugin_name) or false, nil
  if not ok then
    local shim = setmetatable({}, { __call = function(_, default) return default end })
    _G.nixInfo = shim
    if plugin_name then
      package.loaded[plugin_name] = shim
    end
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

-- Snacks must be set up synchronously before VimEnter so that replace_netrw,
-- statuscolumn, and indent hooks are registered at the right time.
-- On Nix:     get_nix_plugin_path returns the store path → packadd it.
-- On non-Nix: bootstrap placed it in packpath as opt → packadd it the same way.
if nixInfo.get_nix_plugin_path('snacks.nvim') or not nixInfo.isNix then
  if pcall(vim.cmd.packadd, 'snacks.nvim') then
    require('config.snacks')
  end
end

-- ── plugin specs (each file returns a table of lze specs) ─────────────────────
nixInfo.lze.load {
  { import = "plugins.snacks"     },
  { import = "plugins.lsp"        },
  { import = "plugins.treesitter" },
  { import = "plugins.completion" },
  { import = "plugins.ui"         },
  { import = "plugins.editing"    },
}
