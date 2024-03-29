{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../common/nixos-configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "smart-kettle";

  networking.firewall.allowedTCPPorts = [
    19999 # netdata
  ];

  services.tailscale.enable = true;

  services.netdata.enable = true;

  modules.home-manager.enable = true;

  # Other stuff

  services.logind.lidSwitchExternalPower = "ignore"; # Don't suspend when closing the lid

  system.autoUpgrade.enable = false; # Disable automatic upgrades from github:buurro/shell

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.systemd-udevd.restartIfChanged = false;

  system.stateVersion = "24.05";
}
