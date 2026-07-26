# Renders docs/macos.md from the darwin base module.
{
  pkgs,
  lib,
  inputs,
}: let
  md = import ./md.nix {inherit lib;};
  cfg = import ../../modules/darwin/base/default.nix {inherit pkgs inputs;};

  masRows =
    lib.mapAttrsToList (
      name: id: [(md.esc name) (md.code (toString id))]
    )
    cfg.homebrew.masApps;

  systemPackages = lib.sort lib.lessThan (map lib.getName cfg.environment.systemPackages);

  fonts = map lib.getName cfg.fonts.packages;

  defaultsRows = lib.concatLists (lib.mapAttrsToList (
      domain: settings:
        lib.mapAttrsToList (
          k: v: [(md.code domain) (md.code k) (md.code (md.value v))]
        )
        settings
    )
    cfg.system.defaults);
in ''
  ${md.banner "modules/darwin/base/default.nix"}

  # macOS setup

  nix-darwin base module shared by all Macs.

  ## Homebrew casks

  ${md.bullets (map md.code cfg.homebrew.casks)}

  ## Mac App Store apps

  ${md.table ["App" "ID"] masRows}

  ## System packages

  ${md.codeList systemPackages}

  ## Fonts

  ${md.codeList fonts}

  ## macOS defaults

  ${md.table ["Domain" "Setting" "Value"] defaultsRows}

  ## Keyboard & security

  ${md.bullets [
    "Remap Caps Lock to Escape: ${md.code (md.value cfg.system.keyboard.remapCapsLockToEscape)}"
    "Touch ID for sudo: ${md.code (md.value cfg.security.pam.services.sudo_local.touchIdAuth)}"
  ]}
''
