{ config, pkgs, lib, ... }:
{
  networking.hostName = "qraspi";

  networking.firewall.allowedTCPPorts = [
    2049 # NFS
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  fileSystems."/mnt/sandisk" = {
    device = "/dev/disk/by-uuid/e389b116-e8a1-481b-8b60-334ef44927a8";
    fsType = "ext4";
  };

  fileSystems."/export/sandisk" = {
    device = "/mnt/sandisk";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export blender.marco.ooo(rw,fsid=0,no_subtree_check)
    /export/sandisk blender.marco.ooo(rw,nohide,insecure,no_subtree_check)
  '';


  # From here is stuff I copied

  console.enable = false;

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
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

