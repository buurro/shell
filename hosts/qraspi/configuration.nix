{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    "${inputs.self}/common/nixos-configuration.nix"
    "${inputs.self}/common/nixos-home-manager.nix"
  ];
  networking.hostName = "qraspi";

  networking.firewall.allowedTCPPorts = [
    80
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    kmod
  ];

  backup-server = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+x9F9RIvU+yRnPIo3ACcBvUv3CZfPmBVaVNVdMx4Zx smart-blender-backups"
    ];
  };

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.qraspi.marco.ooo";
      http_port = 9020;
      http_addr = "127.0.0.1";
    };
  };

  services.prometheus = {
    enable = true;
    port = 9021;
    scrapeConfigs = [{
      job_name = "${config.networking.hostName}";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }
      ];
    }];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  };

  services.loki = {
    enable = true;
    configFile = ./loki-local-config.yaml;
  };

  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${./promtail.yaml}
      '';
    };
  };

  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  console.enable = true;

  boot = {
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*-rpi-4-*.dtb";
      # kernelPackage = pkgs.linuxKernel.kernels.linux_rpi4;
    };
  };

  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  system.stateVersion = "23.05";
}

