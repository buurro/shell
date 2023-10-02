{ config, pkgs, inputs, ... }:
let
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  customUnifi = pkgs.unifi.overrideAttrs (oldAttrs: {
    version = "7.4.162";
    src = pkgs.fetchurl {
      url = "https://dl.ubnt.com/unifi/7.4.162/unifi_sysvinit_all.deb";
      sha256 = "069652f793498124468c985537a569f3fe1d8dd404be3fb69df6b2d18b153c4c";
    };
  });
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "smart-blender";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      6443 # Kubernetes API Server
      3389 # RDP
      80
      443
      8443 # Unifi
    ];
  };

  environment.systemPackages = with pkgs; [
    lightly-qt
    ocs-url
    k3s
    chromium
    mpv
    discord
    customUnifi
    stepmania
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable=traefik"
    ];
  };
  systemd.services.k3s.path = [ pkgs.ipset ];

  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = customUnifi;
    # jrePackage = unstablePkgs.jdk;
  };

  fileSystems."/mnt/nas-fun" = {
    device = "home-nas:/volume1/fun";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  fileSystems."/mnt/nas-od" = {
    device = "home-nas:/volume1/od";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  programs.steam.enable = true;
  services.vscode-server.enable = true;

  services.borgbackup.jobs.downloads-marco = {
    paths = "/home/marco/Downloads";
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/marco/.ssh/backups_ed25519";
    repo = "ssh://backups@qraspi//mnt/nas-backups/smart-blender/downloads-marco";
    compression = "auto,zstd";
    startAt = "daily";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # other stuff

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
  services.openssh.settings.X11Forwarding = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  system.stateVersion = "23.05";
}
