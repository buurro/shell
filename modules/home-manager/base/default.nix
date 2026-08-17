{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  username = config.home.username;
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
in {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nixvim.homeModules.nixvim

    ./vim.nix
    ./zsh.nix
  ];

  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };

  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs;
    [
      alejandra
      argocd
      asciinema
      awscli2
      bat
      bottom
      bun
      cheat
      cmctl
      dig
      duf
      fd
      ffmpeg
      file
      fx
      gh
      gnumake
      htop
      httpie
      iftop
      iperf3
      jq
      kubectl
      kubernetes-helm
      kubeseal
      lazydocker
      nil
      nix-tree
      nixd
      nixfmt
      nixpkgs-fmt
      nnn
      nodejs
      ookla-speedtest
      opentofu
      ranger
      rename
      ripgrep
      ruff
      sshfs
      tabview
      unzip
      uv
      wget
      yt-dlp
    ]
    ++ [
      inputs.agenix.packages."${pkgs.stdenv.system}".default
    ];

  catppuccin.enable = true;
  catppuccin.autoEnable = false;
  catppuccin.flavor = "macchiato";
  catppuccin.fzf.enable = true;
  catppuccin.zellij.enable = true;
  catppuccin.k9s.enable = true;

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${npmGlobalDir}/bin"
  ];

  programs = {
    lsd.enable = true;

    git = {
      enable = true;
      ignores = [
        ".DS_Store"
        ".claude/settings.local.json"
      ];
      signing = {
        format = "ssh";
        key = lib.head inputs.self.users."${username}".ssh.publicKeys;
        signByDefault = true;
        signer = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      settings = {
        init.defaultBranch = "main";

        user.name = inputs.self.users."${username}".fullName;
        user.email = inputs.self.users."${username}".emailFor "git";

        gpg.ssh.allowedSignersFile = "${pkgs.writeText "allowed-signers" (
          lib.concatMapStrings
          (key: "${inputs.self.users."${username}".emailFor "git"} ${key}\n")
          inputs.self.users."${username}".ssh.publicKeys
        )}";
      };
    };

    difftastic.enable = true;

    lazygit = {
      enable = true;
      settings.git = {
        overrideGpg = true;
      };
    };

    k9s.enable = true;

    tmux = {
      enable = true;
      mouse = true;
      prefix = "C-n";
      terminal = "screen-256color";
      extraConfig = ''
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set -g escape-time 10
      '';
      plugins = [pkgs.tmuxPlugins.pain-control];
    };

    zellij = {
      enable = true;
      settings = {
        show_startup_tips = false;
        keybinds = {
          "move" = {
            unbind = {
              _args = ["Ctrl h"];
            };
            "bind \"Ctrl m\"" = {
              SwitchToMode = "Normal";
            };
          };
          "shared_except \"move\" \"locked\"" = {
            unbind = {
              _args = ["Ctrl h"];
            };
            "bind \"Ctrl m\"" = {
              SwitchToMode = "Move";
            };
          };
          "session" = {
            unbind = {
              _args = ["Ctrl o"];
            };
            "bind \"Ctrl u\"" = {
              SwitchToMode = "Normal";
            };
          };
          "shared_except \"session\" \"locked\"" = {
            unbind = {
              _args = ["Ctrl o"];
            };
            "bind \"Ctrl u\"" = {
              SwitchToMode = "Session";
            };
          };
        };
      };
      enableZshIntegration = false;
    };

    alacritty = {
      enable = true;
      settings =
        {
          font.normal.family = "MesloLGSDZ Nerd Font";
          font.size = 18;
        }
        // lib.importTOML ./config/alacritty-catppuccin-mocha.toml;
    };
  };

  home.file.".npmrc".text = ''
    prefix=${npmGlobalDir}
    ignore-scripts=true
  '';
}
