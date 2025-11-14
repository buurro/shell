{ pkgs, ... }:
{
  networking.hostName = "wraspi";

  modules.home-manager.enable = true;

  modules.adguard-home.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "25.05";
}
