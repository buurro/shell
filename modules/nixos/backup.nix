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
    server = mkOption {
      type = types.str;
      default = "qraspi";
      description = "Backup server";
    };
  };

  options.backup-server = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the backup server";
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "SSH authorized keys";
    };
  };

  config = mkMerge [
    (mkIf config.backup-server.enable {
      environment.systemPackages = [ pkgs.borgbackup ];
      users.users.backups = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = config.backup-server.authorizedKeys;
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
        repo = "ssh://backups@${config.backup.server}/mnt/nas-backups/${config.networking.hostName}";
        compression = "auto,zstd";
        startAt = "daily";
      };
    })
  ];
}
