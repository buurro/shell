# Renders docs/cli.md from the home-manager base module.
{
  pkgs,
  lib,
  inputs,
}: let
  md = import ./md.nix {inherit lib;};

  username = lib.head (lib.attrNames inputs.self.users);
  hm = import ../../modules/home-manager/base/default.nix {
    inherit pkgs lib inputs;
    config.home = {
      inherit username;
      homeDirectory = "/Users/${username}";
    };
  };

  packages = lib.sort lib.lessThan (map lib.getName hm.home.packages);

  aliasRows = lib.mapAttrsToList (a: cmd: [(md.code a) (md.code cmd)]) hm.home.shellAliases;

  # Best-effort: shell functions defined in programs.zsh.initContent.
  zshFunctions = let
    lines = lib.filter builtins.isString (builtins.split "\n" hm.programs.zsh.initContent);
    parse = line: let
      m = builtins.match ''([a-zA-Z_][a-zA-Z0-9_]*)\(\) *\{.*'' line;
    in
      if m == null
      then []
      else [(lib.head m)];
  in
    lib.concatMap parse lines;

  enabledPrograms = lib.sort lib.lessThan (lib.attrNames (
    lib.filterAttrs (_: v: builtins.isAttrs v && (v.enable or false)) hm.programs
  ));

  tmuxPlugins = map (p: lib.removePrefix "tmuxplugin-" (lib.getName (p.plugin or p))) hm.programs.tmux.plugins;

  catppuccinIntegrations = lib.sort lib.lessThan (lib.attrNames (
    lib.filterAttrs (_: v: builtins.isAttrs v && (v.enable or false)) hm.catppuccin
  ));

  dotfiles = lib.attrNames hm.home.file;

  alacrittyFont = lib.attrByPath ["font" "normal" "family"] "?" hm.programs.alacritty.settings;
  alacrittyFontSize = lib.attrByPath ["font" "size"] "?" hm.programs.alacritty.settings;
in ''
  ${md.banner "modules/home-manager/base/default.nix"}

  # CLI environment

  Home-manager base module shared by every host.
  Shell: `zsh` (oh-my-zsh, autosuggestions, syntax highlighting) · Prompt: `starship` · Theme: catppuccin (${hm.catppuccin.flavor})

  ## Shell aliases

  ${md.table ["Alias" "Command"] aliasRows}

  ## Shell functions

  Defined in `programs.zsh.initContent`: ${md.codeList zshFunctions}

  oh-my-zsh plugins: ${md.codeList hm.programs.zsh.oh-my-zsh.plugins}

  ## Programs (home-manager managed)

  ${md.bullets (map md.code enabledPrograms)}

  ### tmux

  Prefix: ${md.code hm.programs.tmux.prefix} · Mouse: ${md.code (md.value hm.programs.tmux.mouse)} · Plugins: ${md.codeList tmuxPlugins}

  ### Alacritty

  Font: ${md.code (toString alacrittyFont)} (size ${toString alacrittyFontSize})

  ### Theming

  Catppuccin integrations: ${md.codeList catppuccinIntegrations}

  ## Packages

  ${md.codeList packages}

  ## Managed dotfiles

  ${md.bullets (map md.code dotfiles)}
''
