{ lib, config, pkgs, ... }:
{
  options = {
    modules.kde.enable = lib.mkEnableOption (lib.mdDoc "KDE Plasma");
  };

  config = lib.mkIf config.modules.kde.enable {
    services.xserver.enable = lib.mkDefault true;
    services.xserver.displayManager.sddm.enable = lib.mkDefault true;
    services.desktopManager.plasma6.enable = lib.mkDefault true;
  };
}
