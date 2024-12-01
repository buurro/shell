{ pkgs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
    ../../common/nixos-minimal-configuration.nix
  ];

  networking.hostName = "mixer";

  services.tailscale.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = "/mnt/persist/var/lib/jellyfin";
  };

  fileSystems."/mnt/persist" = {
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1";
    fsType = "ext4";
  };

  fileSystems."/etc/ssh" = {
    device = "/mnt/persist/etc/ssh";
    options = [ "bind" ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "24.11";
}
