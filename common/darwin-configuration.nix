{ config, pkgs, ... }:
let
  python-and-friends = pkgs.python310.withPackages (
    ps: with ps; [ pip ]
  );
in
{
  nixpkgs.config.allowUnfree = true;

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
      "Microsoft Excel" = 462058435;
      "Microsoft Remote Desktop" = 1295203466;
      "Telegram" = 747648890;
    };
    casks = [
      "1password"
      "appcleaner"
      "discord"
      "firefox"
      "fork"
      "google-chrome"
      "iina"
      "iterm2"
      "marta"
      "monitorcontrol"
      "parallels"
      "postgres-unofficial"
      "postico"
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

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
