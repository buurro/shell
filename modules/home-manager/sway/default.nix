# sway port of the old hyprland setup (removed in 3a09509), same
# keybinds, tiling behavior and waybar
{
  pkgs,
  config,
  lib,
  ...
}: let
  c = import ../palette.nix;
  cursorSize = 20;
  mod = "Mod4";
  font = "MesloLGSDZ Nerd Font";
  waybar = lib.getExe config.programs.waybar.package;
  rofi = lib.getExe config.programs.rofi.package;
  brain = pkgs.writeShellScriptBin "brain" ''
    # Path to the log file
    LOG_FILE="''${HOME}/brain.log"

    # Function to log input
    log_input() {
        echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
    }

    # Run Rofi and log input
    rofi -dmenu -p "log this -> " | while IFS= read -r input; do
        if [[ -n $input ]]; then
            log_input "$input"
        fi
    done
  '';
in {
  imports = [
    ../waybar
  ];

  home.packages = with pkgs; [
    alacritty
    chromium
    mako
    libnotify
    playerctl
    nautilus
    mpv
    grim
    slurp
    wl-clipboard
    pavucontrol
  ];

  xdg.enable = true;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = cursorSize;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
      name = "Papirus-Dark";
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    # adw-gtk3 is a gtk3 theme; gtk4/libadwaita apps style themselves and
    # follow the color-scheme below. null is the >=26.05 default, set
    # explicitly to silence the deprecation warning on older stateVersions
    gtk4.theme = null;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  # libadwaita apps (nautilus) ignore the gtk theme and follow this
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs.rofi = {
    enable = true; # wayland support is in the main rofi package now
    font = "${font} 11";
    terminal = lib.getExe pkgs.alacritty;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = "󰀻";
      display-run = "";
      display-window = "";
    };
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral c.text;
      };
      "window" = {
        width = mkLiteral "36%";
        padding = mkLiteral "16px";
        border = mkLiteral "2px";
        border-radius = mkLiteral "16px";
        border-color = mkLiteral c.mauve;
        background-color = mkLiteral c.base;
      };
      "mainbox" = {
        spacing = mkLiteral "12px";
        children = map mkLiteral ["inputbar" "listview"];
      };
      "inputbar" = {
        padding = mkLiteral "10px 14px";
        spacing = mkLiteral "10px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral c.surface0;
        children = map mkLiteral ["prompt" "entry"];
      };
      "prompt" = {
        text-color = mkLiteral c.mauve;
      };
      "entry" = {
        placeholder = "search";
        placeholder-color = mkLiteral c.overlay0;
      };
      "listview" = {
        lines = 8;
        spacing = mkLiteral "4px";
        fixed-height = false;
        scrollbar = false;
      };
      "element" = {
        padding = mkLiteral "8px 12px";
        spacing = mkLiteral "10px";
        border-radius = mkLiteral "10px";
        text-color = mkLiteral c.subtext1;
      };
      "element selected" = {
        background-color = mkLiteral c.mauve;
        text-color = mkLiteral c.crust;
      };
      "element-icon" = {
        size = mkLiteral "22px";
        vertical-align = mkLiteral "0.5";
      };
      "element-text" = {
        vertical-align = mkLiteral "0.5";
        text-color = mkLiteral "inherit";
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "${font} 10";
      width = 380;
      height = 160;
      margin = "16";
      padding = "14";
      border-size = 2;
      border-radius = 12;
      max-icon-size = 48;
      default-timeout = 5000;
      background-color = "${c.mantle}f2";
      text-color = c.text;
      border-color = c.mauve;
      progress-color = "over ${c.surface1}";
      "urgency=low" = {
        border-color = c.surface1;
        text-color = c.subtext0;
      };
      "urgency=high" = {
        border-color = c.red;
        default-timeout = 0;
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway
    checkConfig = false;

    config = {
      modifier = mod;
      floating.modifier = mod;

      fonts = {
        names = [font];
        size = 10.0;
      };

      gaps = {
        inner = 8;
        outer = 4;
      };

      # thin borders, no titlebars: the border colour is the only
      # focus indicator
      window.border = 2;
      window.titlebar = false;
      floating.border = 2;
      floating.titlebar = false;

      colors = let
        entry = border: text: indicator: {
          inherit border text indicator;
          childBorder = border;
          background = c.base;
        };
      in {
        focused = entry c.mauve c.text c.lavender;
        focusedInactive = entry c.surface0 c.subtext0 c.surface0;
        unfocused = entry c.surface0 c.overlay1 c.surface0;
        urgent = entry c.red c.crust c.red;
        placeholder = entry c.surface0 c.subtext0 c.surface0;
        background = c.base;
      };

      window.commands = [
        {
          criteria.app_id = "1Password";
          command = "floating enable";
        }
        {
          criteria.app_id = "org.gnome.Nautilus";
          command = "floating enable";
        }
      ];

      input = {
        "type:keyboard" = {
          xkb_options = "caps:swapescape,compose:rctrl";
          repeat_rate = "50";
          repeat_delay = "250";
        };
        "type:pointer" = {
          natural_scroll = "enabled";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          scroll_factor = "0.2";
        };
      };

      # tokyo-night/wallpapers, misc/cityscape, MIT — credited in README
      output."*".bg = "${./assets/cafe-at-night_00_3840x2160.png} fill";

      bars = []; # waybar instead of swaybar
      startup = [{command = waybar;}];

      keybindings = {
        "${mod}+t" = "exec ${lib.getExe pkgs.alacritty}";
        "${mod}+n" = "exec ${lib.getExe pkgs.chromium}";
        "${mod}+q" = "kill";
        "${mod}+e" = "exec ${lib.getExe pkgs.nautilus} -w";
        "${mod}+Shift+f" = "floating toggle";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+p" = "layout toggle split";
        "${mod}+x" = "exec ${lib.getExe pkgs.grim} - | wl-copy";
        "${mod}+Shift+x" = "exec ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | wl-copy";
        "${mod}+space" = "exec ${rofi} -show drun";
        "${mod}+Shift+space" = "exec ${rofi} -show run";
        "${mod}+i" = "exec ${brain}/bin/brain";
        "${mod}+b" = "exec pkill waybar || ${waybar}";
        "${mod}+Alt+q" = "exit";

        "${mod}+h" = "focus left";
        "${mod}+l" = "focus right";
        "${mod}+k" = "focus up";
        "${mod}+j" = "focus down";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+j" = "move down";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        # special workspace "magic" -> scratchpad
        "${mod}+s" = "scratchpad show";
        "${mod}+Shift+s" = "move scratchpad";

        "${mod}+Ctrl+h" = "resize shrink width 20px";
        "${mod}+Ctrl+l" = "resize grow width 20px";
        "${mod}+Ctrl+k" = "resize shrink height 20px";
        "${mod}+Ctrl+j" = "resize grow height 20px";

        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
      };
    };

    extraConfig = ''
      # sway names the first workspace after whichever `workspace number`
      # binding it happens to hash first, which lands on 10 as often as
      # not. start on 1.
      workspace number 1

      # workspace switching with the scroll wheel, like hyprland's
      # mod+mouse_down/mouse_up
      bindsym --whole-window ${mod}+button4 workspace prev
      bindsym --whole-window ${mod}+button5 workspace next
    '';
  };
}
