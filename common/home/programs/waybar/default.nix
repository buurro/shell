{ ... }:

{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        color: rgb(217, 224, 238);
        font-family: "MesloLGSDZ Nerd Font";
        font-size: 12pt;
        font-weight: bold;
        border-radius: 6px;
        transition-property: background-color;
        transition-duration: 0.5s;
      }
      @keyframes blink_red {
        to {
          background-color: rgb(242, 143, 173);
          color: rgb(26, 24, 38);
        }
      }
      .warning, .critical, .urgent {
        animation-name: blink_red;
        animation-duration: 1s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      window#waybar {
        background-color: transparent;
      }
      window > box {
        margin-top: 5px;
        background-color: transparent;
        /* background-color: #1e1e2a; */
      }
      #mode, #clock, #backlight, #pulseaudio, #network, #battery, #custom-spotify, #tray, #workspaces {
        padding-top: 3px;
        padding-bottom: 3px;
        padding-left: 10px;
        padding-right: 10px;
        margin-left: 5px;
        margin-right: 5px;
        background-color: #1e1e2a;
      }
      #clock {
        color: rgb(217, 224, 238);
      }
      #backlight {
        color: rgb(248, 189, 150);
      }
      #pulseaudio {
        color: rgb(245, 224, 220);
      }
      #network {
        color: #ABE9B3;
      }
      #network.disconnected {
        color: rgb(255, 255, 255);
      }
      #workspaces button.active {
        background-color: rgb(69, 71, 90);
      }
    '';
    settings = [{
      "layer" = "top";
      "position" = "top";
      "height" = 35;
      modules-left = [
        "hyprland/workspaces"
        "tray"
      ];
      modules-center = [
        "clock"
      ];
      modules-right = [
        "custom/spotify"
        "pulseaudio"
        "backlight"
        "network"
      ];
      "pulseaudio" = {
        "scroll-step" = 1;
        "format" = "{icon} {volume}%";
        "format-muted" = "󰖁 Muted";
        "format-icons" = {
          "default" = [ "" "" "" ];
        };
        "on-click" = "pamixer -t";
        "tooltip" = false;
      };
      "clock" = {
        "interval" = 1;
        "format" = "{:%d %b  %H:%M}";
      };
      "network" = {
        "format-disconnected" = "󰯡 Disconnected";
        "format-ethernet" = "󰈀 ✓";
        "format-linked" = "󰖪 {essid} (No IP)";
        "format-wifi" = "󰖩 {essid}";
        "interval" = 1;
        "tooltip" = true;
        "tooltip-format" = "{ifname} {ipaddr}/{cidr}";
      };
      "tray" = {
        "spacing" = 6;
        "icon-size" = 18;
      };
      "custom/spotify" = {
        "format" = "{}";
        "escape" = true;
        "interval" = 5;
        "exec" = "playerctl -f '{{artist}} - {{title}}' -p spotify metadata";
        "exec-if" = "pgrep spotify";
      };
      "hyprland/workspaces" = {
        "format" = "{icon}";
      };
    }];
  };
}
