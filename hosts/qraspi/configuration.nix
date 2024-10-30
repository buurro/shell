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

  networking.firewall.allowedTCPPorts = [
    3001
  ];
  networking.firewall.allowedUDPPorts = [
    53
  ];

  services.adguardhome = {
    enable = true;
    openFirewall = true;
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

