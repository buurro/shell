{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    "${inputs.self}/common/nixos-configuration.nix"
  ];

  networking.hostName = "wraspi";

  modules.home-manager.enable = true;

  age.secrets."risaro.la" = {
    file = ../../secrets/risaro.la.age;
  };

  users.groups."sslcerts" = { };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = inputs.self.users.marco.email;
    server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    group = "sslcerts";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets."risaro.la".path;
  };
  security.acme.certs."risaro.la" = {
    domain = "*.risaro.la";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "25.05";
}

