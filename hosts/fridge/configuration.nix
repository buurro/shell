{ ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "fridge";

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
    options = [ "x-systemd.automount" "noauto" ];
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  system.stateVersion = "25.11";
}
