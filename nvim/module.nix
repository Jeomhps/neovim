inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  # Makes plugins built from flake inputs (prefixed "plugins-") available as
  # config.nvim-lib.neovimPlugins.<name>
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  # Config directory — init.lua lives here alongside this file
  config.settings.config_directory = ./.;

  # ── Colorscheme option ───────────────────────────────────────────────────────
  # Exposes the catppuccin flavour to Lua via:
  #   nixInfo("mocha", "settings", "colorscheme")
  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "mocha"; # latte | frappe | macchiato | mocha
  };

  # catppuccin must NOT be lazy: colors/catppuccin-*.lua calls require('catppuccin') on line 1,
  # and opt packages don't have their lua/ dir in the require path until packadd is called.
  # As a start plugin it's always in rtp, so the require succeeds.
  config.specs.catppuccin = {
    data = pkgs.vimPlugins.catppuccin-nvim;
  };

  # ── Lazy loading framework ───────────────────────────────────────────────────
  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  # ── Clipboard ─────────────────────────────────────────────────────────────────
  # "wsl"    → win32yank in PATH + unnamedplus  (NixOS-WSL / Windows)
  # "system" → just unnamedplus, no extra tool  (macOS, Linux with X/Wayland)
  # "none"   → leave clipboard untouched
  options.settings.clipboard = lib.mkOption {
    type = lib.types.enum [ "wsl" "system" "none" ];
    default = "wsl";
    description = "Clipboard integration mode passed to Lua via nixInfo.";
  };

  config.specs.clipboard = {
    data = null;
    extraPackages = lib.optionals (config.settings.clipboard == "wsl") [
      # wsl-paste: fast clipboard reader for WSL.
      #
      # Preferred path  → win32yank.exe (native Windows binary, ~0 ms startup).
      #   Install on the Windows host once:  scoop install win32yank
      #   or:  winget install equalsraf.win32yank
      #
      # Fallback path   → PowerShell Get-Clipboard (~300-700 ms startup).
      #   Works out of the box, no extra Windows software needed.
      (pkgs.writeShellScriptBin "wsl-paste" ''
        if command -v win32yank.exe > /dev/null 2>&1; then
          win32yank.exe -o --lf
        else
          powershell.exe -NoLogo -NoProfile -NonInteractive -c Get-Clipboard | tr -d '\r'
        fi
      '')
      # wslview: opens a URL / file in the default Windows application.
      # typst-preview.nvim detects WSL and calls wslview to open the preview
      # in the host browser. explorer.exe does the same thing and is always
      # available in WSL without any extra Windows-side software.
      # This is used by typst-preview.nvim to open the preview in the host browser
      # when running in WSL.
      (pkgs.writeShellScriptBin "wslview" ''
        explorer.exe "$@"
      '')
    ];
  };

  # ── Language specs (extra packages / LSPs) ────────────────────────────────────
  config.specs.nix = {
    data = null;
    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];
  };

  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [ lazydev-nvim ];
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.typst = {
    # Provide tinymist (Typst language server) in the Nix environment so
    # the server binary is on PATH for Nix-managed Neovim.
    data = null;
    extraPackages = with pkgs; [
      tinymist
    ];
  };

  # ── General plugins ───────────────────────────────────────────────────────────
  config.specs.general = {
    after = [ "lze" ];
    lazy = true;
    extraPackages = with pkgs; [ lazygit tree-sitter trash-cli ];
    data = with pkgs.vimPlugins; [
    { data = vim-sleuth; lazy = false; }
    { data = mini-nvim; lazy = false; }
    snacks-nvim
    typst-preview-nvim
    nvim-lspconfig
    nvim-surround
    vim-startuptime
    blink-cmp
    blink-compat
    cmp-cmdline
    colorful-menu-nvim
    lualine-nvim
      gitsigns-nvim
      which-key-nvim
      fidget-nvim
      nvim-lint
      conform-nvim
      nvim-treesitter-textobjects
      rainbow-delimiters-nvim
      # withAllGrammars bakes 170+ parser directories into rtp, scanning them
      # on every startup is a major source of latency — list only what you use.
      # Run `nix repl` and browse `pkgs.tree-sitter-grammars` to find more names.
      (nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-lua
        tree-sitter-nix
        tree-sitter-python
        tree-sitter-javascript
        tree-sitter-typescript
        tree-sitter-tsx
        tree-sitter-rust
        tree-sitter-go
        tree-sitter-c
        tree-sitter-cpp
        tree-sitter-json
        tree-sitter-yaml
        tree-sitter-toml
        tree-sitter-markdown
        tree-sitter-markdown-inline
        tree-sitter-bash
        tree-sitter-html
        tree-sitter-css
        tree-sitter-vim
        tree-sitter-vimdoc
        tree-sitter-query
        tree-sitter-regex
        tree-sitter-comment
      ]))
    ];
  };

  # ── specMods: adds an extraPackages field to every spec ──────────────────────
  config.specMods =
    {
      parentSpec ? null,
      parentOpts ? null,
      parentName ? null,
      config,
      ...
    }:
    {
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
        description = "Packages added to PATH when running neovim";
      };
    };

  # Collect all extraPackages across specs into the wrapper's PATH
  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

  # Exposes { specName = true/false; } to Lua via nixInfo for for_cat checks
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  # Helper: build plugins from inputs matching a prefix
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
