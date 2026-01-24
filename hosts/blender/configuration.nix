{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "blender";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      2222
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    allowedUDPPorts = [
      # 8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
  };

  environment.systemPackages = with pkgs; [
    socat
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  services.qemuGuest.enable = true;

  fileSystems."/mnt/nas-fun" = {
    device = "home-nas.lan:/volume1/fun";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  users.users."nas" = {
    uid = 1024;
    isSystemUser = true;
    group = "users";
  };

  modules.home-manager.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  system.stateVersion = "24.05";
}
