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
    "${inputs.self}/modules/network-stuff.nix"
    # "${inputs.self}/modules/hyprland.nix"
    "${inputs.self}/modules/kde.nix"
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
    dig
    socat
    traceroute
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

  services.transmission = {
    enable = true;
    openRPCPort = true;
    settings = {
      download-dir = "/mnt/nas-fun/downloads/complete";
      incomplete-dir = "/mnt/nas-fun/downloads/incomplete";
      watch-dir = "/mnt/nas-fun/downloads/watch";
      watch-dir-enabled = true;
      speed-limit-up = 500;
      speed-limit-up-enabled = true;
      peer-port = 51414;
      download-queue-size = 20;
      rpc-whitelist = "*";
    };
  };
  systemd.services.transmission = {
    after = [ "mnt-nas\\x2dfun.mount" ];
    requires = [ "mnt-nas\\x2dfun.mount" ];
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

  backup = {
    server = "qraspi";
    paths = [
      "/home/marco/Downloads"
      "/var/lib/jellyfin"
      "/var/lib/unifi"
      config.services.sonarr.dataDir
    ];
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
