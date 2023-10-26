{ config, pkgs, inputs, ... }:
let
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  customUnifi = pkgs.unifi.overrideAttrs (oldAttrs: {
    version = "7.4.162";
    src = pkgs.fetchurl {
      url = "https://dl.ubnt.com/unifi/7.4.162/unifi_sysvinit_all.deb";
      sha256 = "069652f793498124468c985537a569f3fe1d8dd404be3fb69df6b2d18b153c4c";
    };
  });
in
{
  imports = [
    ./hardware-configuration.nix
    "${inputs.self}/modules/hyprland.nix"
  ];

  networking.hostName = "smart-blender";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # 6443 # Kubernetes API Server
      # 3389 # RDP
      # 8443 # Unifi
      80
      443
    ];
  };

  environment.systemPackages = with pkgs; [
    k3s
    chromium
    mpv
    discord
    customUnifi
    stepmania
    pavucontrol
    unstablePkgs.osu-lazer-bin
    obs-studio
    spotify
    unstablePkgs.vscode.fhs

    # jellyfin hardware acceleration
    vaapiVdpau
    libvdpau-va-gl
    libva-utils
  ];

  services.k3s = {
    enable = false;
    role = "server";
    extraFlags = toString [
      "--disable=traefik"
    ];
  };
  # systemd.services.k3s.path = [ pkgs.ipset ];

  services.transmission = {
    enable = true;
    openRPCPort = true;
    settings = {
      download-dir = "/mnt/nas-fun/downloads/complete";
      incomplete-dir = "/mnt/nas-fun/downloads/incomplete";
      watch-dir = "/mnt/nas-fun/downloads/watch";
      watch-dir-enabled = true;
      speed-limit-up = 100;
      speed-limit-up-enabled = true;
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "marcoburro98@gmail.com";
    # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    group = "nginx";
    dnsProvider = "cloudflare";
    credentialsFile = "/var/lib/secrets/cloudflare-blender-acme";
    dnsPropagationCheck = false;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  security.acme.certs."blender.marco.ooo" = { };
  services.nginx.virtualHosts."blender.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "blender.marco.ooo";
    default = true;
    locations."/" = {
      root = "${pkgs.nginx}/html";
    };
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "nas";
    group = "users";
    dataDir = "/mnt/nas-od/sonarr/config";
  };
  security.acme.certs."sonarr.pine.marco.ooo" = { };
  services.nginx.virtualHosts."sonarr.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "sonarr.pine.marco.ooo";
    locations."/" = {
      proxyPass = "http://localhost:8989";
      proxyWebsockets = true;
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  security.acme.certs."jellyfin.pine.marco.ooo" = { };
  services.nginx.virtualHosts."jellyfin.pine.marco.ooo" = {
    forceSSL = true;
    useACMEHost = "jellyfin.pine.marco.ooo";
    locations."/" = {
      proxyPass = "http://localhost:8096";
      proxyWebsockets = true;
    };
  };

  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = customUnifi;
  };
  services.nginx.virtualHosts."unifi.pine.marco.ooo" = {
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
    ];
    extraConfig = ''
      location /wss/ {
        proxy_pass https://localhost:8443;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_read_timeout 86400;
      }

      location / {
        proxy_pass https://localhost:8443/; # The Unifi Controller Port
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
      }
    '';
  };

  services.vscode-server.enable = true;

  services.borgbackup.jobs.${config.networking.hostName} = {
    paths = [
      "/home/marco/Downloads"
      "/home/marco/Documents/github"
    ];
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/marco/.ssh/backups_ed25519";
    repo = "ssh://backups@qraspi//mnt/nas-backups/${config.networking.hostName}";
    compression = "auto,zstd";
    startAt = "daily";
  };

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marco" ];
    };
    steam.enable = true;
  };

  fileSystems."/mnt/nas-fun" = {
    device = "home-nas:/volume1/fun";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  fileSystems."/mnt/nas-od" = {
    device = "home-nas:/volume1/od";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  fileSystems."/media/anime" = {
    depends = [ "/mnt/nas-fun" ];
    device = "/mnt/nas-fun/media/anime";
    fsType = "none";
    options = [ "bind" ];
  };

  users.users."nas" = {
    uid = 1024;
    isSystemUser = true;
    group = "users";
  };

  users.users."vm" = {
    isNormalUser = true;
    shell = "${inputs.self.images.vm}/bin/run-nixos-vm";
    openssh.authorizedKeys.keys = config.users.users.marco.openssh.authorizedKeys.keys;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "23.05";
}
