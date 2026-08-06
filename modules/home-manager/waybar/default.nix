{lib, ...}: let
  c = import ../palette.nix;
  font = "MesloLGSDZ Nerd Font";
  # every palette entry becomes a gtk named color, so the stylesheet
  # below never spells out a hex
  colorDefs = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: hex: "@define-color ${name} ${hex};") c
  );
in {
  programs.waybar = {
    enable = true;
    style = ''
      ${colorDefs}

      * {
        font-family: "${font}", sans-serif;
        font-size: 11pt;
        font-weight: 500;
        min-height: 0;
        border: none;
        box-shadow: none;
        text-shadow: none;
      }

      window#waybar {
        background: transparent;
        color: @text;
      }

      /* one floating pill per section instead of one per module */
      .modules-left,
      .modules-center,
      .modules-right {
        background-color: alpha(@base, 0.88);
        border: 1px solid alpha(@surface1, 0.6);
        border-radius: 14px;
        padding: 0 4px;
      }

      #workspaces button {
        color: @overlay1;
        padding: 0 9px;
        margin: 4px 2px;
        border-radius: 10px;
        transition: background-color 0.2s ease, color 0.2s ease;
      }
      #workspaces button:hover {
        background-color: alpha(@surface0, 0.9);
        color: @text;
      }
      #workspaces button.visible {
        color: @subtext1;
      }
      #workspaces button.focused {
        background-color: @mauve;
        color: @crust;
      }
      #workspaces button.urgent {
        background-color: @red;
        color: @crust;
      }

      #mode {
        color: @crust;
        background-color: @peach;
        padding: 0 10px;
        margin: 4px 2px;
        border-radius: 10px;
      }

      #clock {
        color: @text;
        font-weight: 600;
        padding: 0 16px;
      }

      #custom-spotify,
      #backlight,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 10px;
        margin: 4px 0;
      }
      /* thin separators inside the right pill */
      #backlight,
      #pulseaudio,
      #network,
      #battery {
        border-left: 1px solid alpha(@surface1, 0.5);
      }

      #custom-spotify {
        color: @green;
      }
      #backlight {
        color: @peach;
      }
      #pulseaudio {
        color: @sky;
      }
      #pulseaudio.muted {
        color: @overlay1;
      }
      #network {
        color: @teal;
      }
      #network.disconnected {
        color: @overlay1;
      }
      #battery {
        color: @green;
      }
      #battery.warning {
        color: @yellow;
      }
      #battery.critical {
        color: @red;
      }
      /* only a nearly dead battery earns the right to flash */
      #battery.critical:not(.charging) {
        animation: blink 1s linear infinite alternate;
      }
      @keyframes blink {
        to {
          background-color: @red;
          color: @crust;
        }
      }

      tooltip {
        background-color: @mantle;
        border: 1px solid @surface1;
        border-radius: 10px;
      }
      tooltip label {
        color: @text;
        padding: 4px;
      }
    '';
    settings = [
      {
        layer = "top";
        position = "top";
        height = 34;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;
        spacing = 6;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "custom/spotify"
          "backlight"
          "pulseaudio"
          "network"
          "battery"
          "tray"
        ];
        pulseaudio = {
          scroll-step = 1;
          format = "{icon}  {volume}%";
          format-muted = "󰖁  muted";
          format-icons = {
            headphone = "󰋋";
            default = ["󰕿" "󰖀" "󰕾"];
          };
          on-click = "pavucontrol";
          tooltip = false;
        };
        clock = {
          interval = 30;
          format = "{:%H:%M}";
          format-alt = "{:%a %d %b  %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            format = {
              today = "<span color='${c.mauve}'><b>{}</b></span>";
              days = "<span color='${c.text}'>{}</span>";
              weekdays = "<span color='${c.overlay1}'>{}</span>";
            };
          };
        };
        network = {
          format-disconnected = "󰯡  offline";
          format-ethernet = "󰈀  {ifname}";
          format-linked = "󰖪  {essid}";
          format-wifi = "󰖩  {essid}";
          interval = 5;
          tooltip-format = "{ifname}  {ipaddr}/{cidr}";
        };
        tray = {
          spacing = 8;
          icon-size = 16;
        };
        "custom/spotify" = {
          format = "  {}";
          escape = true;
          interval = 5;
          max-length = 40;
          exec = "playerctl -f '{{artist}} - {{title}}' -p spotify metadata";
          exec-if = "pgrep spotify";
        };
        "sway/workspaces" = {
          format = "{name}";
        };
        "sway/mode" = {
          format = "{}";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-plugged = "󰚥  {capacity}%";
          format-icons = ["󰁺" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹"];
          tooltip-format = "{timeTo}";
        };
        backlight = {
          format = "{icon}  {percent}%";
          format-icons = ["󰃞" "󰃟" "󰃠"];
        };
      }
    ];
  };
}
