# on-demand linux builder: the vm doesn't run at boot, start it only
# around builds with the `linux-builder` helper command.
#
# nix-darwin registers the builder as a launchd *system* daemon, so
# starting it would need sudo. the vm itself needs no root — vzvm
# (Virtualization.framework) forwarding host port 31022 into the guest
# over vsock, which the root nix-daemon ssh'es into regardless of who
# owns the process — so we leave that daemon dormant (RunAtLoad/
# KeepAlive off) and run the same create-builder script as a launchd
# *user agent*, whose gui domain launchctl controls without sudo.
#
# why vz and not nix-darwin's default qemu package: nixpkgs replaced 9p
# with virtiofs in qemu-vm.nix, and virtiofsd only builds on linux, so
# `darwin.linux-builder` no longer evaluates on a darwin host. the vz
# variant shares directories through Virtualization.framework's own
# virtiofs device instead, and gets x86_64-linux via rosetta for free.
#
# note: the `build-dir` setting in `config` changes the guest closure,
# which is itself an aarch64-linux build (cores, memory and disk size
# are host-side vzvm settings and leave the stock, cached image alone).
# on an already-bootstrapped host just `linux-builder start` before
# switching and the builder rebuilds its own image. on a fresh host,
# comment out `build-dir` for the first switch (the stock image comes
# from the binary cache), then restore it and switch again with the
# builder running.
{
  config,
  pkgs,
  lib,
  ...
}: let
  port = 31022; # nixpkgs' virtualisation.darwin-builder.hostPort default
  cfg = config.nix.linux-builder;
  builderctl = pkgs.writeShellScriptBin "linux-builder" ''
    set -e
    target="gui/$(id -u)/org.nixos.linux-builder"
    # vzvm's proxy accepts tcp on the port as soon as it starts and holds
    # the connection until sshd in the guest answers on vsock — only an
    # ssh banner (the server talks first) proves the builder can serve
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
    package = pkgs.darwin.linux-builder-vz;
    # one guest serves both: x86_64-linux runs under rosetta (binfmt)
    systems = ["aarch64-linux" "x86_64-linux"];
    ephemeral = true; # wiped on restart, safe to kill
    maxJobs = 4; # concurrent derivations
    config = {
      virtualisation.cores = 8;
      virtualisation.darwin-builder = {
        memorySize = 12 * 1024;
        # sparse raw data disk (still named nixos.qcow2 so `ephemeral`
        # wipes it), so capacity is free on the host. it backs the guest's
        # writable store overlay at /nix/.rw-store and, via build-dir
        # below, build scratch; sized for disk image builds (closure +
        # raw image + converted qcow2 at peak)
        diskSize = 80 * 1024;
      };
      # the vz guest's root — and with it /tmp and /nix/var — is a tmpfs
      # capped at half the ram, whereas the qemu guest kept it on the data
      # disk. without this, build scratch lands in ram and anything past
      # ~6g fails with enospc
      nix.settings.build-dir = "/nix/.rw-store/build";
      systemd.tmpfiles.rules = ["d /nix/.rw-store/build 0755 root root -"];
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
        # the vz data disk is a raw image that keeps the qcow2 name
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
  # builder image by nixpkgs' nix-builder profile (the backend-neutral
  # half shared by the qemu and vz builders).
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
