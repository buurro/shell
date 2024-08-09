{ lib, pkgs, ... }:
{

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
      };

      background = [{
        path = "${../../assets/cafe-at-night_00_3840x2160.png}";
        blur_passes = 4;
        blur_size = 12;
      }];

      input-field = [{
        size.width = 250;
        placeholder_text = "";
      }];

      label = [
        {
          text = "¯\\_(ツ)_/¯";
          font_size = 64;
          color = "rgb(200, 200, 200)";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${lib.getExe pkgs.hyprlock}";
        before_sleep_cmd = "${lib.getExe pkgs.hyprlock}";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "${lib.getExe pkgs.hyprlock}";
        }
        {
          timeout = 900;
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
