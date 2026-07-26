# Renders docs/vim.md from the nixvim configuration.
{
  pkgs,
  lib,
}: let
  md = import ./md.nix {inherit lib;};
  cfg = (import ../../modules/home-manager/base/vim.nix {inherit pkgs;}).programs.nixvim;

  modeNames = {
    n = "normal";
    i = "insert";
    v = "visual";
    x = "visual";
    t = "terminal";
  };
  modeStr = m: let
    ms =
      if builtins.isList m
      then m
      else [m];
  in
    lib.concatStringsSep ", " (map (x: modeNames.${x} or x) ms);

  # --------------------------------------------------------------------------
  # Keymaps declared in `keymaps`
  # --------------------------------------------------------------------------
  keymapRows =
    map (
      k: [
        (md.code k.key)
        (modeStr (k.mode or "n"))
        (md.esc (k.options.desc or ""))
        (
          if builtins.isString k.action
          then md.code k.action
          else "*(lua)*"
        )
      ]
    )
    cfg.keymaps;

  # --------------------------------------------------------------------------
  # Keymaps buried in raw Lua (extraConfigLua, gitsigns on_attach).
  # Best-effort: scans for `vim.keymap.set("<mode>", "<key>", ...)` and
  # `map("<mode>", "<key>", ...)` calls and pulls out the desc.
  # --------------------------------------------------------------------------
  extractLuaKeymaps = lua: let
    parts = builtins.split ''(vim\.keymap\.set|map)\('' lua;
    chunks = lib.filter builtins.isString (lib.tail parts);
    parse = chunk: let
      m = builtins.match ''[[:space:]]*"([a-zA-Z]+)",[[:space:]]*"([^"]*)".*'' chunk;
      d = builtins.match ''.*desc = "([^"]*)".*'' chunk;
    in
      if m == null
      then null
      else {
        mode = lib.head m;
        key = lib.elemAt m 1;
        desc =
          if d == null
          then ""
          else lib.head d;
      };
  in
    lib.filter (x: x != null) (map parse chunks);

  luaKeymapRows = src:
    map (k: [(md.code k.key) (modeStr k.mode) (md.esc k.desc)]) (extractLuaKeymaps src);

  # --------------------------------------------------------------------------
  # Plugin-owned keymaps
  # --------------------------------------------------------------------------
  telescopeRows =
    lib.mapAttrsToList (
      key: v: [(md.code key) (md.code v.action) (md.esc (v.options.desc or ""))]
    )
    cfg.plugins.telescope.keymaps;

  lspRows =
    lib.mapAttrsToList (
      key: v: [(md.code key) (md.code v.action) (md.esc (v.desc or ""))]
    )
    cfg.plugins.lsp.keymaps.lspBuf;

  whichKeyRows =
    map (
      s: [(md.code s.__unkeyed-1) (md.esc s.group)]
    )
    cfg.plugins.which-key.settings.spec;

  # --------------------------------------------------------------------------
  # Plugins / LSP / tooling
  # --------------------------------------------------------------------------
  enabledPlugins = lib.sort lib.lessThan (lib.attrNames (
    lib.filterAttrs (_: v: builtins.isAttrs v && (v.enable or false)) cfg.plugins
  ));

  lspServers = lib.sort lib.lessThan (lib.attrNames (
    lib.filterAttrs (_: v: v.enable or false) cfg.plugins.lsp.servers
  ));

  ftToolRows = attrs:
    lib.mapAttrsToList (
      ft: tools: [(md.code ft) (md.codeList tools)]
    )
    attrs;

  grammars = lib.sort lib.lessThan (
    map (g: lib.removePrefix "tree-sitter-" (lib.getName g))
    cfg.plugins.treesitter.grammarPackages
  );

  extraPackages = lib.sort lib.lessThan (map lib.getName cfg.extraPackages);

  optRows = lib.mapAttrsToList (name: v: [(md.code name) (md.code (md.value v))]) cfg.opts;

  autoCmdRows =
    map (
      a: [
        (md.codeList (lib.toList a.event))
        (md.code (a.group or ""))
        (md.esc (a.desc or ""))
      ]
    )
    cfg.autoCmd;
in ''
  ${md.banner "modules/home-manager/base/vim.nix"}

  # Neovim configuration

  Declarative [nixvim](https://github.com/nix-community/nixvim) setup.
  Leader key: `${
    if cfg.globals.mapleader == " "
    then "<Space>"
    else cfg.globals.mapleader
  }` · Colorscheme: `tokyonight` (${cfg.colorschemes.tokyonight.settings.style})

  ## Keymaps

  ${md.table ["Key" "Mode" "Description" "Action"] keymapRows}

  ### Key groups (which-key)

  ${md.table ["Prefix" "Group"] whichKeyRows}

  ### Telescope

  ${md.table ["Key" "Picker" "Description"] telescopeRows}

  ### LSP

  ${md.table ["Key" "Action" "Description"] lspRows}

  ### Git hunks (buffer-local, via gitsigns)

  ${md.table ["Key" "Mode" "Description"] (luaKeymapRows cfg.plugins.gitsigns.settings.on_attach.__raw)}

  ### Extra keymaps (defined in Lua)

  ${md.table ["Key" "Mode" "Description"] (luaKeymapRows cfg.extraConfigLua)}

  ## Plugins

  ${md.bullets (map md.code enabledPlugins)}

  ## Language support

  ### LSP servers

  ${md.bullets (map md.code lspServers)}

  ### Formatters (conform-nvim)

  ${md.table ["Filetype" "Formatters"] (ftToolRows cfg.plugins.conform-nvim.settings.formatters_by_ft)}

  ### Linters (nvim-lint)

  ${md.table ["Filetype" "Linters"] (ftToolRows cfg.plugins.lint.lintersByFt)}

  ### Treesitter grammars

  ${md.codeList grammars}

  ## Options

  ${md.table ["Option" "Value"] optRows}

  ## Autocommands

  ${md.table ["Event(s)" "Group" "Description"] autoCmdRows}

  ## Extra packages

  ${md.codeList extraPackages}
''
