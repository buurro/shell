{ lib, config, pkgs, ... }:
let
  cfg = config.modules.authelia;
in
{
  options = with lib; {
    modules.authelia = {
      enable = mkEnableOption (mdDoc "Authelia");
      domain = mkOption {
        type = types.str;
      };
      jwtSecretFile = mkOption {
        type = types.str;
      };
      storageEncryptionKeyFile = mkOption {
        type = types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable
    ({
      services.nginx.additionalModules = [
        pkgs.nginxModules.develkit
        pkgs.nginxModules.set-misc
      ];
      services.authelia.instances."main" = {
        enable = true;
        settings = {
          server.port = 9095;
          access_control.default_policy = "two_factor";

          authentication_backend.file.path = "/var/lib/authelia-main/users_database.yml";
          notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";
          storage.local.path = "/var/lib/authelia-main/db.sqlite3";

          session.domain = cfg.domain;
        };

        secrets.jwtSecretFile = config.age.secrets."authelia.jwtSecretFile".path;
        secrets.storageEncryptionKeyFile = config.age.secrets."authelia.storageEncryptionKeyFile".path;
      };

      services.nginx.virtualHosts = {
        "auth.${cfg.domain}" = {
          forceSSL = true;
          useACMEHost = cfg.domain;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9095";
            extraConfig = builtins.readFile ./proxy.conf;
          };
          locations."/api/verify" = {
            proxyPass = "http://127.0.0.1:9095";
          };
        };
      };
    });
}
