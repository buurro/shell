# Renders docs/hosts.md from the flake's host configurations.
{
  lib,
  self,
}: let
  md = import ./md.nix {inherit lib;};

  # config.nixpkgs.system instead of pkgs.stdenv: reading it doesn't force a
  # pkgs instantiation, which throws for platforms nixpkgs has dropped
  # (x86_64-darwin) even though the pinned config still evaluates.
  hostRow = kind: name: c: [
    (md.code name)
    kind
    (md.code c.config.nixpkgs.system)
    (md.code (toString c.config.system.stateVersion))
  ];

  rows =
    lib.mapAttrsToList (hostRow "nix-darwin") self.darwinConfigurations
    ++ lib.mapAttrsToList (hostRow "NixOS") self.nixosConfigurations;

  images = lib.attrNames self.images;

  vms = lib.attrNames (removeAttrs self.packages.aarch64-darwin ["docs"]);
in ''
  ${md.banner "flake.nix"}

  # Hosts

  ${md.table ["Host" "Type" "System" "State version"] rows}

  ## Images

  Buildable via `nix build .#images.<name>`: ${md.codeList images}

  ## Local VMs

  Runnable from apple silicon with `nix run .#<name>`: ${md.codeList vms}
  (`linux-builder start` first if the config changed). Disk state lives in
  `<name>.qcow2` in the directory you run from; delete it to reset.

  `swayvm` opens a fullscreen cocoa window — see [gui.md](gui.md).
  `headlessvm` keeps the console in the terminal you launched it from
  (`ctrl-a x` quits) and forwards ssh to `localhost:2222`.
''
