{ config, pkgs, inputs, lib, ... }:
{
  options = {
    modules.hyprland.enable = lib.mkEnableOption (lib.mdDoc "Hyprland");
  };

  config = lib.mkIf config.modules.hyprland.enable (lib.mkMerge [
    (import ../desktop.nix { inherit pkgs; })
    {
      environment.systemPackages = with pkgs; [
        kitty
        mako
        libnotify
        rofi-wayland
      ];

      fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
          (nerdfonts.override { fonts = [ "Meslo" ]; })
        ];
      };

      services.xserver.enable = true;
      services.xserver.displayManager.sddm.enable = true;

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      programs.waybar = {
        enable = true;
      };
    }
  ]);
}
