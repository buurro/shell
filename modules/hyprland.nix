{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kitty
    waybar
    mako
    libnotify
    rofi-wayland
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];
  };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
}
