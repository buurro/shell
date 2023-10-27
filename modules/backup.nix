{ pkgs, lib, config, ... }:
with lib;
{
  options.backup = {
    enable = mkOption {
      type = types.bool;
      default = config.backup.paths != [ ];
      description = "Enable the backup service";
    };
    paths = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = "Paths to backup";
    };
  };

  options.backup-server = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the backup server";
    };
  };

  config = mkMerge [
    (mkIf config.backup-server.enable {
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
    })
    (mkIf config.backup.enable {
      environment.systemPackages = [ pkgs.borgbackup ];
      environment.variables.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/marco/.ssh/backups_ed25519";
      services.borgbackup.jobs.${config.networking.hostName} = {
        paths = config.backup.paths;
        encryption.mode = "none";
        environment.BORG_RSH = config.environment.variables.BORG_RSH;
        repo = "ssh://backups@qraspi//mnt/nas-backups/${config.networking.hostName}";
        compression = "auto,zstd";
        startAt = "daily";
      };
    })
  ];
}
