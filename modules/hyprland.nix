{ pkgs, inputs, ... }:
{
  imports = [
    ./desktop.nix
  ];

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
    package = hyprland;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  programs.waybar = {
    enable = true;
    package = waybar;
  };
}
