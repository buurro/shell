{ pkgs, config, inputs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "cache";

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };

  environment.systemPackages = with pkgs; [
    iftop
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "200m";
    virtualHosts = {
      "default" = {
        serverName = "_";
        default = true;
        rejectSSL = true;
        root = pkgs.writeTextDir "index.html" ''
          hello
        '';
      };
      "cache.risaro.la" = {
        forceSSL = true;
        useACMEHost = "risaro.la";
        locations."/" = {
          proxyPass = "http://localhost:1234";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = inputs.self.users.marco.email;
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      group = "nginx";
      dnsProvider = "cloudflare";
      credentialsFile = "/mnt/persist/var/lib/secrets/cloudflare-cache-acme";
    };
    certs."risaro.la" = {
      domain = "*.risaro.la";
    };
  };

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

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  system.stateVersion = "25.11";
}
