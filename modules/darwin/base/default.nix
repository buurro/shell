{ pkgs, inputs, ... }:
let
  python-and-friends = pkgs.python312.withPackages (
    ps: with ps; [ pip pipx ]
  );

  spotify-volume-control = pkgs.fetchFromGitHub {
    owner = "buurro";
    repo = "spotify-volume-skhd";
    rev = "main";
    sha256 = "sha256-JCVo2WMkn9OgKAzjofvFotU/nPpwHh/bMiq0s7XmY2s=";
  };
in
{
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "blender";
    systems = [ "x86_64-linux" "aarch64-linux" ];
    sshUser = "marco";
  }];
  nixpkgs.config.allowUnfree = true;
  nix.settings.trusted-users = [ "root" "marco" ];
  users.users."marco".home = "/Users/marco";
  system.primaryUser = "marco";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.marco = import ../../home-manager/base/default.nix;
    extraSpecialArgs = {
      inherit inputs;
      hyprland = false;
    };
  };

  programs.zsh.enable = true;
  programs.zsh.promptInit = "";

  environment.systemPackages = with pkgs; [
    _1password-cli
    gnumake
    python-and-friends
    vim
    coreutils
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
      "ghostty"
      "google-chrome"
      "iina"
      "iterm2"
      "jellyfin-media-player"
      "mac-mouse-fix"
      "marta"
      "monitorcontrol"
      "notion"
      "postico"
      "raspberry-pi-imager"
      "raycast"
      "slack"
      "spotify"
      "tailscale"
      "visual-studio-code"
      "zed"
    ];
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.meslo-lg
    ];
  };

  system.defaults = {
    trackpad.TrackpadThreeFingerDrag = true;
    trackpad.Clicking = true; # tap to click

    NSGlobalDomain.KeyRepeat = 1;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.AppleKeyboardUIMode = 3; # navigate ui with keyboard
    NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;

    dock.autohide = true;
    dock.autohide-delay = 0.01;
    dock.autohide-time-modifier = 0.01;
    dock.show-recents = false;


    finder.AppleShowAllExtensions = true;
    finder.ShowPathbar = true;

    screencapture.location = "~/Pictures/screenshots";
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
