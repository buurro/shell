# Aggregates all generated docs into one directory.
# Build with `nix build .#docs`, or sync into docs/ with `nix run .#docs`.
{
  pkgs,
  lib,
  inputs,
}: let
  files = {
    "vim.md" = import ./vim.nix {inherit pkgs lib;};
    "cli.md" = import ./cli.nix {inherit pkgs lib inputs;};
    "macos.md" = import ./macos.nix {inherit pkgs lib inputs;};
    "hosts.md" = import ./hosts.nix {
      inherit lib;
      inherit (inputs) self;
    };
    "gui.md" = import ./gui.nix {
      inherit lib;
      inherit (inputs) self;
    };
  };
in
  pkgs.linkFarm "docs" (lib.mapAttrsToList (name: text: {
      inherit name;
      path = pkgs.writeText name text;
    })
    files)
