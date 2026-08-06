# on-demand linux builder: the vm doesn't run at boot, start it only
# around builds with the `linux-builder` helper command.
#
# note: the `config` block changes the vm image derivation, which is
# itself an aarch64-linux build. on an already-bootstrapped host just
# `linux-builder start` before switching and the builder rebuilds its
# own image. on a fresh host, comment out `config` for the first
# switch (the stock image comes from the binary cache), then restore
# it and switch again with the builder running.
{
  pkgs,
  lib,
  ...
}: let
  port = 31022; # fixed in the darwin.linux-builder package
  builderctl = pkgs.writeShellScriptBin "linux-builder" ''
    set -e
    case "''${1:-}" in
      start)
        sudo launchctl kickstart system/org.nixos.linux-builder
        printf 'waiting for builder ssh'
        until nc -z localhost ${toString port} 2>/dev/null; do
          printf .
          sleep 1
        done
        echo " up"
        ;;
      stop)
        sudo launchctl kill TERM system/org.nixos.linux-builder
        ;;
      status)
        if nc -z localhost ${toString port} 2>/dev/null; then
          echo running
        else
          echo stopped
        fi
        ;;
      *)
        echo "usage: linux-builder start|stop|status" >&2
        exit 1
        ;;
    esac
  '';
in {
  nix.linux-builder = {
    enable = true;
    ephemeral = true; # wiped on restart, safe to kill
    maxJobs = 4; # concurrent derivations
    config = {
      virtualisation.cores = 8;
      virtualisation.darwin-builder = {
        memorySize = 12 * 1024;
        diskSize = 40 * 1024;
      };
    };
  };

  launchd.daemons.linux-builder.serviceConfig = {
    KeepAlive = lib.mkForce false;
    RunAtLoad = lib.mkForce false;
  };

  environment.systemPackages = [builderctl];
}
