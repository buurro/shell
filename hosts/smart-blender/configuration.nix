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
    "${inputs.self}/modules/hyprland.nix"
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
    pavucontrol
    unstablePkgs.osu-lazer-bin
    obs-studio
    spotify
    unstablePkgs.vscode.fhs
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

  services.borgbackup.jobs.${config.networking.hostName} = {
    paths = [
      "/home/marco/Downloads"
      "/home/marco/Documents/github"
    ];
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/marco/.ssh/backups_ed25519";
    repo = "ssh://backups@qraspi//mnt/nas-backups/${config.networking.hostName}";
    compression = "auto,zstd";
    startAt = "daily";
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "marco" ];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];

  # other stuff

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "23.05";
}
