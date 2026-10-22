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

  vim.health.start("YAML tooling")
  check_bin("yamllint", { hint = "nix: rebuild | non-nix: install manually (nvim-lint has no Mason fallback)" })
  check_bin("yamlfmt", { hint = "nix: rebuild | non-nix: install manually (conform has no Mason fallback)" })
  check_bin("actionlint", { hint = "lints .github/workflows | nix: rebuild | non-nix: install manually" })
  check_bin("zizmor", { hint = "security-lints .github/workflows | nix: rebuild | non-nix: install manually" })
  check_bin("pinact", { hint = "<leader>cp pins actions to SHAs (set GITHUB_TOKEN to avoid rate limits) | nix: rebuild | non-nix: install manually" })

  vim.health.start("Terraform / OpenTofu")
  check_bin("terraform-ls", { hint = "nix: rebuild | non-nix: installs via Mason on first .tf file" })
  check_bin("tflint", { hint = "nix: rebuild | non-nix: install manually (nvim-lint has no Mason fallback)" })
  check_bin("tofu", { hint = "formats .tf via tofu_fmt (or `terraform` for terraform_fmt) | nix: rebuild | non-nix: install manually" })

  vim.health.start("Kubernetes / Helm")
  check_bin("helm_ls", { hint = "nix: rebuild | non-nix: installs via Mason on first helm template" })

  vim.health.start("Ansible")
  check_bin("ansible-language-server", { hint = "nix: rebuild | non-nix: installs via Mason on first playbook" })
  check_bin("ansible-lint", { hint = "nix: rebuild | non-nix: install manually (nvim-lint has no Mason fallback)" })

  vim.health.start("JSON")
  check_bin("vscode-json-language-server", { hint = "nix: rebuild | non-nix: installs via Mason (json-lsp) on first .json file" })
  check_bin("jq", { hint = "formats json via conform | nix: rebuild | non-nix: install manually" })

  vim.health.start("Markdown")
  check_bin("marksman", { hint = "nix: rebuild | non-nix: installs via Mason on first .md file" })
  check_bin("markdownlint", { hint = "nix: rebuild | non-nix: install manually (nvim-lint has no Mason fallback)" })
  check_bin("codespell", { hint = "typo linter for markdown / commit messages | nix: rebuild | non-nix: install manually" })

  vim.health.start("TOML")
  check_bin("taplo", { hint = "LSP + formatter | nix: rebuild | non-nix: installs via Mason on first .toml file" })

  vim.health.start("Python")
  check_bin("basedpyright-langserver", { hint = "nix: rebuild | non-nix: installs via Mason on first .py file" })
  check_bin("ruff", { hint = "formats python via conform | nix: rebuild | non-nix: install manually" })
end

return M
