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
      name: id: [
        (md.link (md.esc name) "https://apps.apple.com/app/id${toString id}")
        (md.code (toString id))
      ]
    )
    cfg.homebrew.masApps;

  # Tap-qualified casks (foo/tap/bar) aren't listed on formulae.brew.sh.
  caskLink = c:
    if lib.hasInfix "/" c
    then md.code c
    else md.link (md.code c) "https://formulae.brew.sh/cask/${c}";

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

  ${md.bullets (map caskLink cfg.homebrew.casks)}

  ## Mac App Store apps

  ${md.table ["App" "ID"] masRows}

  ## System packages

  ${md.pkgLinkList cfg.environment.systemPackages}

  ## Fonts

  ${md.pkgLinkList cfg.fonts.packages}

  ## macOS defaults

  ${md.table ["Domain" "Setting" "Value"] defaultsRows}

  ## Keyboard & security

  ${md.bullets [
    "Remap Caps Lock to Escape: ${md.code (md.value cfg.system.keyboard.remapCapsLockToEscape)}"
    "Touch ID for sudo: ${md.code (md.value cfg.security.pam.services.sudo_local.touchIdAuth)}"
  ]}
''
