{ inputs, lib, pkgs, ... }:
{

  imports = [
    inputs.hyprlock.homeManagerModules.hyprlock
    inputs.hypridle.homeManagerModules.hypridle
  ];

  programs.hyprlock = {
    enable = true;

    general = {
      grace = 5;
      hide_cursor = true;
    };

    backgrounds = [{
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

    input-fields = [{
      size.width = 250;
      placeholder_text = "";
    }];

    labels = [
      {
        text = "¯\\_(ツ)_/¯";
        font_size = 64;
        color = "rgb(30, 30, 46)";
      }
    ];
  };

  services.hypridle = {
    enable = true;
    lockCmd = "${lib.getExe pkgs.hyprlock}";
    beforeSleepCmd = "${lib.getExe pkgs.hyprlock}";
    listeners = [
      {
        timeout = 120;
        onTimeout = "${lib.getExe pkgs.hyprlock}";
      }
      {
        timeout = 300;
        onTimeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        onResume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
}
