{
  config,
  inputs,
  lib,
  ...
}: {
  options = {
    modules.adguard-home.enable = lib.mkEnableOption "AdGuard Home";
  };

  config = lib.mkIf config.modules.adguard-home.enable {
    age.secrets."risaro.la" = {
      file = ../../secrets/risaro.la.age;
    };

    users.groups."sslcerts" = {};

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = inputs.self.users.marco.email;
        # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        group = "sslcerts";
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets."risaro.la".path;
      };
      certs."risaro.la" = {
        domain = "*.risaro.la";
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
      853
    ];

    networking.firewall.allowedUDPPorts = [
      853
      53
    ];

    services.adguardhome = {
      enable = true;
      openFirewall = true;
    };

    users.groups."adguardhome" = {};

    users.users.adguardhome = {
      group = "adguardhome";
      isSystemUser = true;
      extraGroups = ["sslcerts"];
    };
  };
}
