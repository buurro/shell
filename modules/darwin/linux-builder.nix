# on-demand linux builder: the vm doesn't run at boot, start it only
# around builds with the `linux-builder` helper command.
#
# nix-darwin registers the builder as a launchd *system* daemon, so
# starting it would need sudo. the vm itself needs no root — qemu with
# user networking on port 31022, which the root nix-daemon ssh'es into
# regardless of who owns the process — so we leave that daemon dormant
# (RunAtLoad/KeepAlive off) and run the same create-builder script as a
# launchd *user agent*, whose gui domain launchctl controls without sudo.
#
# note: the `config` block changes the vm image derivation, which is
# itself an aarch64-linux build. on an already-bootstrapped host just
# `linux-builder start` before switching and the builder rebuilds its
# own image. on a fresh host, comment out `config` for the first
# switch (the stock image comes from the binary cache), then restore
# it and switch again with the builder running.
{
  config,
  pkgs,
  lib,
  ...
}: let
  port = 31022; # fixed in the darwin.linux-builder package
  cfg = config.nix.linux-builder;
  builderctl = pkgs.writeShellScriptBin "linux-builder" ''
    set -e
    target="gui/$(id -u)/org.nixos.linux-builder"
    # qemu's hostfwd accepts tcp as soon as the vm process starts, long
    # before the guest can serve builds — only an ssh banner (the server
    # talks first) proves sshd inside the guest is answering
    up() {
      printf "" | nc -w 2 localhost ${toString port} 2>/dev/null | grep -q "^SSH-"
    }
    case "''${1:-}" in
      start)
        launchctl kickstart "$target"
        printf 'waiting for builder ssh'
        until up; do
          printf .
          sleep 1
        done
        echo " up"
        ;;
      stop)
        launchctl kill TERM "$target"
        ;;
      status)
        if up; then
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
        # sparse qcow2, so capacity is free on the host; sized for disk
        # image builds, whose raw scratch file lands on this disk over
        # virtiofs (closure + raw image + converted qcow2 at peak)
        diskSize = 80 * 1024;
      };
    };
  };

  # keep the module's system daemon loaded but inert; the user agent
  # below is what actually runs the vm
  launchd.daemons.linux-builder.serviceConfig = {
    KeepAlive = lib.mkForce false;
    RunAtLoad = lib.mkForce false;
  };

  # like the system daemon's script (modules/nix/linux-builder.nix in
  # nix-darwin), but with the working dir and the cert-sharing TMPDIR
  # moved from /var/lib and /run into $HOME, and — crucially — without
  # create-builder's add-keys step: that step sudo-installs the client
  # key into /etc/nix whenever it drifts, which a user agent can never
  # do. instead the key lives with the vm in $HOME and buildMachines
  # below points the root nix-daemon straight at it. TMPDIR deliberately
  # avoids /tmp: macos purges files there after 3 idle days, which would
  # eat the certs shared with the guest.
  launchd.user.agents.linux-builder = {
    environment = {
      inherit (config.environment.variables) NIX_SSL_CERT_FILE;
    };

    script = ''
      workdir="$HOME/.cache/linux-builder"
      export TMPDIR="$workdir/tmp" USE_TMPDIR=1
      rm -rf "$TMPDIR"
      mkdir -p "$TMPDIR"
      trap 'rm -rf "$TMPDIR"' EXIT
      cd "$workdir"
      export KEYS="$workdir/keys"
      mkdir -p "$KEYS"
      if [ ! -e "$KEYS/builder_ed25519" ] || [ ! -e "$KEYS/builder_ed25519.pub" ]; then
        rm -f "$KEYS/builder_ed25519" "$KEYS/builder_ed25519.pub"
        ${pkgs.openssh}/bin/ssh-keygen -q -f "$KEYS/builder_ed25519" -t ed25519 -N "" -C 'builder@localhost'
      fi
      ${lib.optionalString cfg.ephemeral ''
        rm -f ${cfg.package.nixosConfig.networking.hostName}.qcow2
      ''}
      ${cfg.package.run-builder}/bin/run-builder
    '';

    serviceConfig = {
      KeepAlive = false;
      RunAtLoad = false;
    };
  };

  # replace nix-darwin's machine entry (sshKey /etc/nix/builder_ed25519,
  # kept fresh only by create-builder's sudo) with the same entry reading
  # the key from the agent's dir; the nix-daemon runs as root and can
  # read it there. publicHostKey stays the static key baked into the
  # builder image by nixpkgs' nix-builder-vm profile.
  nix.buildMachines = lib.mkForce [
    {
      hostName = "linux-builder";
      sshUser = "builder";
      sshKey = "/Users/marco/.cache/linux-builder/keys/builder_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
      inherit (cfg) mandatoryFeatures maxJobs protocol speedFactor supportedFeatures systems;
    }
  ];

  environment.systemPackages = [builderctl];
}
