{ config, pkgs, inputs, nixos-hardware, ... }:
{
  imports = [
    "${inputs.self}/common/nixos-configuration.nix"
    ./hardware-configuration.nix
  ];
  networking.hostName = "smart-kettle"; # Define your hostname.
  services.vscode-server.enable = true;

  modules.home-manager.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.systemd-udevd.restartIfChanged = false;

  system.stateVersion = "23.05";
}
