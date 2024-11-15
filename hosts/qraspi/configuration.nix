{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    "${inputs.self}/common/nixos-configuration.nix"
  ];
  networking.hostName = "qraspi";

  modules.home-manager.enable = true;

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

  age.secrets."risaro.la" = {
    file = ../../secrets/risaro.la.age;
  };

  users.groups."sslcerts" = { };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = inputs.self.users.marco.email;
    # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    group = "sslcerts";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets."risaro.la".path;
  };
  security.acme.certs."risaro.la" = {
    domain = "*.risaro.la";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    853
  ];
  networking.firewall.allowedUDPPorts = [
    53
  ];

  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };
  users.groups."adguardhome" = { };
  users.users.adguardhome = {
    group = "adguardhome";
    isSystemUser = true;
    extraGroups = [ "sslcerts" ];
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

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  system.stateVersion = "23.05";
}

