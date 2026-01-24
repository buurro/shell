{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
    ../../modules/nixos/network-stuff.nix
  ];

  networking.hostName = "fridge";

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };

  environment.systemPackages = with pkgs; [
    iftop
  ];

  networking.vpn = {
    enable = true;
    wgConfigFile = "/mnt/persist/var/lib/secrets/wg0.conf";
    ip = "10.197.52.11/24";
    portForwards = {
      # note: this string becomes the service name
      "portforward-transmission" = {
        localPort = 9091;
        namespacePort = 9091;
      };
    };
    services = [
      "transmission"
    ];
  };

  users.users."nas" = {
    uid = 1024;
    isSystemUser = true;
    group = "users";
  };

  services.transmission = {
    enable = true;

    package = pkgs.transmission_4.overrideAttrs (finalAttrs: previousAttrs: {
      version = "4.0.5";
      src = pkgs.fetchFromGitHub {
        owner = "transmission";
        repo = "transmission";
        rev = finalAttrs.version;
        hash = "sha256-gd1LGAhMuSyC/19wxkoE2mqVozjGPfupIPGojKY0Hn4=";
        fetchSubmodules = true;
      };
    });

    home = "/mnt/persist/var/lib/transmission";

    settings = {
      download-dir = "/mnt/nas-fun/downloads/complete";
      incomplete-dir = "/mnt/nas-fun/downloads/incomplete";
      watch-dir = "/mnt/nas-fun/downloads/watch";
      watch-dir-enabled = true;
      speed-limit-up = 1000;
      speed-limit-up-enabled = true;
      alt-speed-up = 0;
      alt-speed-down = 0;
      peer-port = 51414;
      download-queue-size = 20;
      rpc-whitelist-enabled = false;
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist-enabled = false;
      ratio-limit-enabled = true;
      ratio-limit = 3;
    };
  };

  systemd.services.transmission = {
    after = ["mnt-nas\\x2dfun.mount"];
    requires = ["mnt-nas\\x2dfun.mount"];
  };

  services.sonarr = {
    enable = true;
    dataDir = "/mnt/persist/var/lib/sonarr/.config/NzbDrone";
    user = "nas";
    group = "users";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "200m";
    virtualHosts = {
      "sonarr.risaro.la" = {
        forceSSL = true;
        useACMEHost = "risaro.la";
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.sonarr.settings.server.port}";
          proxyWebsockets = true;
        };
      };
      "torrent.risaro.la" = {
        forceSSL = true;
        useACMEHost = "risaro.la";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = inputs.self.users.marco.email;
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      group = "nginx";
      dnsProvider = "cloudflare";
      credentialsFile = "/mnt/persist/var/lib/secrets/cloudflare-fridge-acme";
    };
    certs."risaro.la" = {
      domain = "*.risaro.la";
    };
  };

  services.qemuGuest.enable = true;

  services.openssh.hostKeys = [
    {
      type = "rsa";
      bits = 4096;
      path = "/mnt/persist/etc/ssh/ssh_host_rsa_key";
    }
    {
      type = "ed25519";
      path = "/mnt/persist/etc/ssh/ssh_host_ed25519_key";
    }
  ];

  fileSystems."/mnt/persist" = {
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1";
    fsType = "ext4";
  };

  fileSystems."/mnt/nas-fun" = {
    device = "dmz-nas.dmz:/volume1/fun";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  system.stateVersion = "25.11";
}
