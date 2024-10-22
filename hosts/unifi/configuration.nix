{ pkgs, inputs, ... }:
{
  imports = [
    ../../common/nixos-minimal-configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "unifi";
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "23.05";
}
