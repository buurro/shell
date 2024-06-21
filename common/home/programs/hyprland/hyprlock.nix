{ inputs, lib, pkgs, ... }:
{

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
      };

      background = [{
        path = # doesn't seem to work with jpg
          let
            wallpaper = pkgs.stdenv.mkDerivation {
              name = "wallpaper";
              src = ../../assets;
              nativeBuildInputs = [ pkgs.imagemagick ];
              buildPhase = ''
                convert $src/acrylic.jpg out.png
              '';
              installPhase = ''
                mkdir -p $out
                cp out.png $out
              '';
            };
          in
          "${wallpaper}/out.png";
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
          color = "rgb(30, 30, 46)";
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
          timeout = 180;
          on-timeout = "${lib.getExe pkgs.hyprlock}";
        }
        {
          timeout = 240;
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
