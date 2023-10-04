{ config, pkgs, lib, inputs, ... }:
{
  networking.hostName = "wraspi";

  networking.firewall.allowedTCPPorts = [
    # 2049 # NFS
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    kmod
  ];

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

