{ config, pkgs, inputs, ... }:
let
  python-and-friends = pkgs.python311.withPackages (
    ps: with ps; [ pip pipx black ]
  );
in
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.trusted-users = [ "root" "marco" ];
  users.users."marco".home = "/Users/marco";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.marco = import "${inputs.self}/common/home.nix";
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  programs.zsh.enable = true;
  programs.zsh.promptInit = "";

  environment.systemPackages = with pkgs; [
    python-and-friends
    gnumake
    vim
  ];

  homebrew = {
    enable = true;
    masApps = {
      "1Password for Safari" = 1569813296;
      "Magnet" = 441258766;
      "Microsoft Excel" = 462058435;
      "Microsoft Word" = 462054704;
      "Microsoft Remote Desktop" = 1295203466;
      "Speedtest by Ookla" = 1153157709;
      "Telegram" = 747648890;
      "WireGuard" = 1451685025;
    };
    casks = [
      "1password"
      "1password/tap/1password-cli"
      "appcleaner"
      "audacity"
      "dbeaver-community"
      "discord"
      "firefox"
      "fork"
      "google-chrome"
      "iina"
      "iterm2"
      "jellyfin-media-player"
      "marta"
      "monitorcontrol"
      "obsidian"
      "postgres-unofficial"
      "postico"
      "private-internet-access"
      "raspberry-pi-imager"
      "raycast"
      "slack"
      "spotify"
      "syncthing"
      "tailscale"
      "visual-studio-code"
    ];
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];
  };

  system.defaults = {
    trackpad.TrackpadThreeFingerDrag = true;
    trackpad.Clicking = true; # tap to click

    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.AppleKeyboardUIMode = 3; # navigate ui with keyboard
    NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";

    dock.autohide = true;
    dock.autohide-delay = 0.01;
    dock.autohide-time-modifier = 0.01;
    dock.show-recents = false;


    finder.AppleShowAllExtensions = true;
    finder.ShowPathbar = true;

    screencapture.location = "~/Pictures/screenshots";

    CustomSystemPreferences = {
      NSGlobalDomain = {
        NSWindowShouldDragOnGesture = true;
      };
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

  services.karabiner-elements.enable = false;

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    extraConfig = ''
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      yabai -m config layout bsp


      # Window rules
      yabai -m rule --add app="^(Calculator|System Preferences|System Settings|Archive Utility|Finder)$" manage=off
      # Anki card preview
      yabai -m rule --add title="^Preview" manage=off
      yabai -m rule --add title="^Preferences" manage=off
      yabai -m rule --add title="Preferences$" manage=off
      yabai -m rule --add title="^Settings" manage=off
      yabai -m rule --add app="^Steam$" manage=off
      yabai -m rule --add app="^CrossOver$" manage=off
      yabai -m rule --add app="^League of Legends$" manage=off
      yabai -m rule --add app="^Notes$" manage=off
      yabai -m rule --add app="^QuickTime Player$" manage=off
      yabai -m rule --add app="^League of Legends$" manage=off
      yabai -m rule --add app="^Numi$" manage=off
      yabai -m rule --add app="^Kawa$" manage=off
      yabai -m rule --add app="^Weather$" manage=off
      yabai -m rule --add app="^Speedtest$" manage=off
      yabai -m rule --add app="^1Password" manage=off


      # Set all padding and gaps to 20pt (default: 0)
      # yabai -m config top_padding    0
      # yabai -m config bottom_padding 0
      # yabai -m config left_padding   0
      # yabai -m config right_padding  0
      yabai -m config window_gap     12

      # Useful optional stuff
      # yabai -m config focus_follows_mouse autofocus
      yabai -m config window_shadow float
      yabai -m config window_border_width 1
      yabai -m config active_window_border_color  0xBF999999
      # yabai -m config window_opacity on
      # yabai -m config normal_window_opacity 0.9

      # Drag/resizes Windows with mouse without having to grab the edges first by holding ctrl
      yabai -m config mouse_modifier ctrl
      yabai -m config mouse_action1 move
      yabai -m config mouse_action2 resize
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      # https://github.com/koekeishiya/yabai/wiki/Commands#focus-display
      # https://github.com/koekeishiya/dotfiles/blob/master/skhd/skhdrc

      # .blacklist []

      # Navigation
      alt + ctrl - a : yabai -m window --focus west
      alt + ctrl - d : yabai -m window --focus east
      alt + ctrl - s : yabai -m window --focus south
      alt + ctrl - w : yabai -m window --focus north

      # Moving windows
      alt + shift - a : yabai -m window --warp west
      alt + shift - d : yabai -m window --warp east
      alt + shift - s : yabai -m window --warp south
      alt + shift - w : yabai -m window --warp north

      # Rotate layout
      alt - l : yabai -m space --rotate 90
      # Balance the layout
      alt - k : yabai -m space --balance

      # Move focus container to display (use "space" instead of display to move to just per space instead)
      # alt + shift - x : yabai -m window --display 1 --focus # main monitor
      # alt + shift - z : yabai -m window --display 2 --focus # vertical
      # alt + shift - c : yabai -m window --display 3 --focus # laptop

      # Move focus container to space
      alt + ctrl - 1 : yabai -m window --space 1 --focus
      alt + ctrl - 2 : yabai -m window --space 2 --focus
      alt + ctrl - 3 : yabai -m window --space 3 --focus
      alt + ctrl - 4 : yabai -m window --space 4 --focus
      alt + ctrl - 5 : yabai -m window --space 5 --focus
      alt + ctrl - 6 : yabai -m window --space 6 --focus
      alt + ctrl - 7 : yabai -m window --space 7 --focus
      alt + ctrl - 8 : yabai -m window --space 8 --focus
      alt + ctrl - 9 : yabai -m window --space 9 --focus


      # Resize windows
      alt - a : yabai -m window --resize left:-100:0 ; yabai -m window --resize right:-100:0
      alt - s : yabai -m window --resize bottom:0:100 ; yabai -m window --resize top:0:100
      alt - w : yabai -m window --resize top:0:-100 ; yabai -m window --resize bottom:0:-100
      alt - d : yabai -m window --resize right:100:0 ; yabai -m window --resize left:100:0


      # Float / Unfloat window
      alt - space : yabai -m window --toggle float

      # Make fullscreen
      alt - f         : yabai -m window --toggle zoom-fullscreen
      
      # Toggle padding on/off
      alt - g         : yabai -m space --toggle padding --toggle gap
      
      # Disable padding overall
      alt - y         : yabai -m config top_padding 0 \ yabai -m config bottom_padding 0 \ yabai -m config left_padding 0 \ yabai -m config right_padding 0 \ yabai -m config window_gap 0
      alt - u         : yabai -m config window_gap 12
      # Toggle floating/bsp
      alt - h         : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')

      # Change desktop
      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      alt - 6 : yabai -m space --focus 6
      alt - 7 : yabai -m space --focus 7
      alt - 8 : yabai -m space --focus 8
      alt - 9 : yabai -m space --focus 9
      alt - 0 : yabai -m space --focus 10

      # Control Audio Output Device
      # alt - e : SwitchAudioSource -s "FiiO K5 Pro"
      # alt - r : SwitchAudioSource -s "MacBook Pro Speakers"
    '';
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
