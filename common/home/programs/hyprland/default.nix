{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alacritty
    mako
    libnotify
    rofi-wayland
    hyprlock
    playerctl
    gnome.nautilus
    mpv
  ];

  xdg.portal.enable = true;
  xdg.portal.configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];

  services.mako = {
    enable = true;
    defaultTimeout = 5000;
  };

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1,preferred,auto,1"
      "desc:SOMEASUSMONITOR,3440x1440@85,auto,auto"
      "desc:LG Electronics LG ULTRAGEAR 101NTKFSV589,2560x1440@144,auto,auto"
    ];

    env = [
      "XCURSOR_SIZE,24"
    ];

    misc = {
      disable_hyprland_logo = true;
    };

    exec-once = [
      "waybar"
      # "${pkgs.mpvpaper}/bin/mpvpaper '*' https://someurl"
    ];

    windowrule = [
      "float,1Password"
      "float,org.gnome.Nautilus"
      "size 1300 900,org.gnome.Nautilus"
      "move 100 100,org.gnome.Nautilus"
    ];

    animations = {
      enabled = true;
      bezier = "myBezier, 0.25, 0.46, 0.45, 0.96";
      animation = [
        "windows, 1, 2, myBezier"
        "windowsOut, 1, 2, default, popin 80%"
        "border, 1, 2, default"
        "borderangle, 1, 2, default"
        "fade, 1, 2, default"
        "workspaces, 1, 2, default"
      ];
    };

    dwindle.preserve_split = true;

    decoration = {
      rounding = 0;
    };

    input = {
      natural_scroll = true;
      touchpad = {
        natural_scroll = true;
      };
      repeat_rate = 50;
      repeat_delay = 250;
      kb_options = [
        "caps:swapescape"
      ];
    };

    "$mod" = "SUPER";

    bind = [
      "$mod, T, exec, alacritty"
      "$mod, Q, killactive,"
      "$mod, E, exec, nautilus"
      "$mod, V, togglefloating,"
      "$mod, F, fullscreen,"
      "$mod, P, togglesplit,"
      "$mod SHIFT, P, swapsplit,"
      "$mod, space, exec, rofi -show run"
      "$mod ALT, Q, exec, hyprctl dispatch exit"
      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, K, movefocus, u"
      "$mod, J, movefocus, d"
      "$mod SHIFT, H, movewindow, l"
      "$mod SHIFT, L, movewindow, r"
      "$mod SHIFT, K, movewindow, u"
      "$mod SHIFT, J, movewindow, d"
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
    ];
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    binde = [
      "$mod CTRL, H, resizeactive, -20 0"
      "$mod CTRL, L, resizeactive, 20 0"
      "$mod CTRL, K, resizeactive, 0 -20"
      "$mod CTRL, J, resizeactive, 0 20"
    ];
  };
}
