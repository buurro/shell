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
in ''
  ${md.banner "flake.nix"}

  # Hosts

  ${md.table ["Host" "Type" "System" "State version"] rows}

  ## Images

  Buildable via `nix build .#images.<name>`: ${md.codeList images}
''
