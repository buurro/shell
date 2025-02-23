{ config, pkgs, inputs, ... }:
let
  authelia = import ../../modules/authelia/stuff.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    "${inputs.self}/common/nixos-configuration.nix"
  ];

  networking.hostName = "blender";

  networking.enableIPv6 = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      2222
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    allowedUDPPorts = [
      # 8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
  };

  environment.systemPackages = with pkgs; [
    dig
    socat
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  networking.vpn = {
    enable = true;
    wgConfigFile = "/var/lib/secrets/wg0.conf";
    ip = "10.197.52.6/24";
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

  services.k3s = {
    enable = false;
    role = "server";
    extraFlags = toString [
      "--disable=traefik"
    ];
  };

  services.transmission = {
    enable = true;
    openRPCPort = true;
    settings = {
      download-dir = "/mnt/nas-fun/downloads/complete";
      incomplete-dir = "/mnt/nas-fun/downloads/incomplete";
      watch-dir = "/mnt/nas-fun/downloads/watch";
      watch-dir-enabled = true;
      speed-limit-up = 1000;
      speed-limit-up-enabled = true;
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
    after = [ "mnt-nas\\x2dfun.mount" ];
    requires = [ "mnt-nas\\x2dfun.mount" ];
  };
  services.nginx.virtualHosts."torrent.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "pine.marco.ooo";
    extraConfig = authelia.nginx.enableVhost;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9091";
      extraConfig = authelia.nginx.enableLocation;
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = inputs.self.users.marco.email;
    # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    group = "nginx";
    dnsProvider = "cloudflare";
    credentialsFile = "/var/lib/secrets/cloudflare-blender-acme";
    # dnsPropagationCheck = false;
    # dnsResolver = "1.1.1.1:53";
  };
  security.acme.certs."pine.marco.ooo" = {
    domain = "*.pine.marco.ooo";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "200m";
  };

  age.secrets."authelia.jwtSecretFile" = {
    file = ../../secrets/authelia.jwtSecretFile.age;
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };
  age.secrets."authelia.storageEncryptionKeyFile" = {
    file = ../../secrets/authelia.storageEncryptionKeyFile.age;
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };

  modules.authelia = {
    enable = true;
    domain = "pine.marco.ooo";
    jwtSecretFile = config.age.secrets."authelia.jwtSecretFile".path;
    storageEncryptionKeyFile = config.age.secrets."authelia.storageEncryptionKeyFile".path;
  };

  services.sonarr = {
    enable = true;
    user = "nas";
    group = "users";
  };
  services.nginx.virtualHosts."sonarr.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "pine.marco.ooo";
    locations."/" = {
      proxyPass = "http://localhost:8989";
      proxyWebsockets = true;
    };
  };

  services.radarr = {
    enable = true;
    user = "nas";
    group = "users";
  };
  services.nginx.virtualHosts."radarr.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "pine.marco.ooo";
    locations."/" = {
      proxyPass = "http://localhost:7878";
      proxyWebsockets = true;
    };
  };

  services.jellyseerr = {
    enable = true;
  };
  services.nginx.virtualHosts."jellyseerr.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "pine.marco.ooo";
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.jellyseerr.port}";
      proxyWebsockets = true;
    };
  };

  services.netdata = {
    enable = false;
  };
  services.nginx.virtualHosts."netdata.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "pine.marco.ooo";
    extraConfig = authelia.nginx.enableVhost;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19999";
      extraConfig = authelia.nginx.enableLocation;
    };
  };

  services.qemuGuest.enable = true;

  backup = {
    server = "qraspi";
    paths = [
      "/home/marco/Documents/projects"
      "/home/marco/.zsh_history"
      "/home/marco/.local/share/zoxide"
      "/home/marco/.ssh"
      config.services.sonarr.dataDir
      "/var/lib/secrets"
    ];
  };

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marco" ];
    };
  };

  fileSystems."/mnt/persist" = {
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
    fsType = "ext4";
  };

  fileSystems."/mnt/nas-fun" = {
    device = "home-nas.lan:/volume1/fun";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  users.users."nas" = {
    uid = 1024;
    isSystemUser = true;
    group = "users";
  };

  modules.hyprland.enable = false;
  modules.home-manager.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  system.stateVersion = "24.05";
}
