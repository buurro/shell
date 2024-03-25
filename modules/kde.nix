{ lib, config, pkgs, ... }:
{
  options = {
    modules.kde.enable = lib.mkEnableOption (lib.mdDoc "KDE Plasma");
  };

  config = lib.mkIf config.modules.kde.enable (lib.mkMerge [
    (import ./desktop.nix { inherit pkgs; })
    {
      services.xserver.enable = lib.mkDefault true;
      services.xserver.displayManager.sddm.enable = lib.mkDefault true;
      services.desktopManager.plasma6.enable = lib.mkDefault true;
    }
  ]);
}
