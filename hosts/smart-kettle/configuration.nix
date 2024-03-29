{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../common/nixos-configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "smart-kettle"; # Define your hostname.

  modules.home-manager.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.systemd-udevd.restartIfChanged = false;

  system.stateVersion = "23.05";
}
