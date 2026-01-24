{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "mixer";

  networking.firewall.allowedTCPPorts = [80 443];

  environment.systemPackages = with pkgs; [
    # jellyfin hardware acceleration
    libva-vdpau-driver
    libvdpau-va-gl
    libva-utils
  ];

  age.secrets."somefile.zip" = {
    file = ../../secrets/somefile.zip.age;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = inputs.self.users.marco.email;
    # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    group = "nginx";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets."somefile.zip".path;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "200m";
  };
  services.nginx.virtualHosts."default" = {
    serverName = "_";
    default = true;
    rejectSSL = true;
    root = pkgs.writeTextDir "index.html" ''
      hello
    '';
  };

  # hardware acceleration stuff
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.jellyfin = {
    enable = true;
    # dataDir = "/mnt/persist/var/lib/jellyfin";
  };
  security.acme.certs."jellyfin.somefile.zip" = {
    domain = "jellyfin.somefile.zip";
  };
  services.nginx.virtualHosts."jellyfin.somefile.zip" = {
    forceSSL = true;
    useACMEHost = "jellyfin.somefile.zip";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };
  };

  services.tailscale.enable = true;

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

  fileSystems."/var/lib/jellyfin" = {
    device = "/mnt/persist/var/lib/jellyfin";
    options = ["bind"];
  };

  fileSystems."/mnt/persist" = {
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1";
    fsType = "ext4";
  };

  fileSystems."/mnt/nas-fun" = {
    device = "dmz-nas.dmz:/volume1/fun";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
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
