{ config, lib, inputs, pkgs, ... }:
{
  imports = [
    inputs.hyprland.nixosModules.default
  ];
  options = {
    modules.hyprland.enable = lib.mkEnableOption "Hyprland";
  };

  config = lib.mkIf config.modules.hyprland.enable {
    xdg.portal = {
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
