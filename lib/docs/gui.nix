# Renders docs/gui.md from the sway home-manager configuration.
{
  lib,
  self,
}: let
  md = import ./md.nix {inherit lib;};

  hm = self.nixosConfigurations.swayvm.config.home-manager.users.marco;
  cfg = hm.wayland.windowManager.sway.config;

  # /nix/store/<hash>-foo/bin/foo -> foo; context discarded so the docs
  # don't depend on the vm's linux packages
  clean = s:
    lib.concatStrings (lib.filter builtins.isString
      (builtins.split ''/nix/store/[^ )"']*/bin/'' (builtins.unsafeDiscardStringContext s)));

  prettyKey = k: md.code (lib.replaceStrings ["Mod4"] ["Mod"] k);

  bindRows =
    lib.mapAttrsToList (k: cmd: [(prettyKey k) (md.code (clean cmd))])
    cfg.keybindings;

  wheelRows =
    map (
      l: let
        toks = lib.splitString " " (lib.removePrefix "bindsym --whole-window " (lib.trim l));
      in [
        (prettyKey (lib.head toks))
        (md.code (lib.concatStringsSep " " (lib.tail toks)))
      ]
    ) (lib.filter (l: lib.hasInfix "bindsym" l)
      (lib.splitString "\n" hm.wayland.windowManager.sway.extraConfig));

  ruleRows =
    map (
      w: [(md.code (builtins.toJSON w.criteria)) (md.code w.command)]
    )
    cfg.window.commands;

  waybar = lib.head hm.programs.waybar.settings;
in ''
  ${md.banner "modules/home-manager/sway/default.nix"}

  # GUI (sway)

  Port of the old hyprland setup (removed in `3a09509`). `Mod` is Super;
  inside the `swayvm` VM that's the macOS Cmd key (QEMU runs with
  full-grab, so cmd shortcuts reach the guest — use Ctrl+Option+G to
  release the grab when you need macOS back, e.g. for Cmd+Tab).

  ## Keybindings

  ${md.table ["Key" "Action"] bindRows}

  Mouse, with `Mod` held: left-drag moves floating windows, right-drag
  resizes them.

  ${md.table ["Wheel" "Action"] wheelRows}

  ## Theme

  Catppuccin mocha, defined once in `modules/home-manager/palette.nix`
  and read by sway, waybar, rofi and mako so they can't drift apart.

  ${md.table ["Setting" "Value"] [
    ["accent" "${md.code cfg.colors.focused.border} (mauve) — focused border, selected rofi entry, current workspace, notification border"]
    ["borders" "${md.code "${toString cfg.window.border}px"}, no titlebars"]
    ["gaps" "${md.code "${toString cfg.gaps.inner}px"} between windows, ${md.code "${toString cfg.gaps.outer}px"} around the screen"]
  ]}

  ## Window rules

  ${md.table ["Criteria" "Command"] ruleRows}

  ## Bar (waybar)

  ${md.table ["Position" "Modules"] [
    ["left" (md.codeList waybar.modules-left)]
    ["center" (md.codeList waybar.modules-center)]
    ["right" (md.codeList waybar.modules-right)]
  ]}

  `Mod+b` restarts it if it dies.

  ## The VM

  ```
  linux-builder start   # only needed when the config changed
  nix run .#swayvm
  ```

  greetd auto-starts sway as `marco` (password `marco`). The VM boots
  fullscreen because QEMU's cocoa display only reports its window size
  to the guest at boot. Disk state lives in `swayvm.qcow2` in the
  directory you run it from; delete it to reset. Ctrl+Option+G releases
  the input grab.
''
