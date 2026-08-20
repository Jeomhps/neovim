-- :checkhealth config
-- Verifies external CLI tools this config depends on are actually on PATH.
-- On Nix these come from module.nix's extraPackages (needs a rebuild if
-- missing); on non-Nix, LSP servers install via Mason on first use, but the
-- general-purpose tools (fd, ripgrep, lazygit) must be installed manually.

local M = {}

---@param bin string
---@param opts { hint: string }
local function check_bin(bin, opts)
  if vim.fn.executable(bin) == 1 then
    vim.health.ok(bin)
  else
    vim.health.warn(bin .. " not found on PATH", { opts.hint })
  end
end

function M.check()
  vim.health.start("General tools")
  check_bin("git", { hint = "required for plugin management and gitsigns/lazygit" })
  check_bin("lazygit", { hint = "nix: add to extraPackages | non-nix: install manually" })
  check_bin("rg", { hint = "ripgrep — used by Snacks.picker.grep / grug-far | nix: add to extraPackages | non-nix: install manually" })
  check_bin("fd", { hint = "used by Snacks.picker.files / the dashboard | nix: add to extraPackages | non-nix: install manually" })
  check_bin("trash", { hint = "trash-cli — used by Snacks.explorer delete | nix: add to extraPackages | non-nix: install manually" })

  vim.health.start("Lua")
  check_bin("lua-language-server", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first .lua file" })
  check_bin("stylua", { hint = "nix: rebuild to pick up module.nix changes | non-nix: install manually (conform has no Mason fallback)" })
  check_bin("selene", { hint = "nix: rebuild to pick up module.nix changes | non-nix: install manually (nvim-lint has no Mason fallback)" })

  vim.health.start("Nix")
  check_bin("nixd", { hint = "nix: rebuild to pick up module.nix changes | non-nix: not applicable" })
  check_bin("nixfmt", { hint = "nix: rebuild to pick up module.nix changes | non-nix: not applicable" })
  check_bin("statix", { hint = "nix: rebuild to pick up module.nix changes | non-nix: not applicable" })

  vim.health.start("Typst")
  check_bin("tinymist", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first .typ file" })

  vim.health.start("Go")
  check_bin("go", { hint = "nix: rebuild to pick up module.nix changes | non-nix: install manually" })
  check_bin("gopls", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first .go file" })

  vim.health.start("C / C++")
  check_bin("clangd", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first .c/.cpp file" })

  vim.health.start("YAML")
  check_bin("yaml-language-server", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first .yaml file" })

  vim.health.start("Bash")
  check_bin("bash-language-server", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first shell script" })
  check_bin("shellcheck", { hint = "nix: rebuild to pick up module.nix changes | non-nix: install manually (nvim-lint has no Mason fallback)" })
  check_bin("shfmt", { hint = "nix: rebuild to pick up module.nix changes | non-nix: install manually (conform has no Mason fallback)" })

  vim.health.start("Docker")
  check_bin("docker-langserver", { hint = "nix: rebuild to pick up module.nix changes | non-nix: installs via Mason on first Dockerfile" })
  check_bin("hadolint", { hint = "nix: rebuild to pick up module.nix changes | non-nix: install manually (nvim-lint has no Mason fallback)" })
end

return M
