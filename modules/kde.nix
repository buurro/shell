{ lib, ... }:
{
  imports = [
    ./desktop.nix
  ];

  services.xserver.enable = lib.mkDefault true;
  services.xserver.displayManager.sddm.enable = lib.mkDefault true;
  services.xserver.desktopManager.plasma5.enable = lib.mkDefault true;
}
