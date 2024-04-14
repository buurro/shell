{ pkgs, ... }:
{
  imports = [
    ../../common/nixos-configuration.nix
  ];

  networking.hostName = "hyprvm";

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    firefox
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  modules.home-manager.enable = true;
  modules.hyprland.enable = true;

  system.autoUpgrade.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
