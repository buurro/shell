{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.borgbackup ];

  users.users.backups = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+x9F9RIvU+yRnPIo3ACcBvUv3CZfPmBVaVNVdMx4Zx smart-blender-backups"
    ];
  };

  fileSystems."/mnt/nas-backups" = {
    device = "home-nas:/volume1/backups";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
}
