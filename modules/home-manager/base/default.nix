{ pkgs, inputs, config, lib, ... }:

let
  username = config.home.username;
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ../programs
  ];

  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ];
  };

  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    argocd
    asciinema
    awscli2
    bat
    bottom
    bun
    cachix
    cheat
    cmctl
    dig
    duf
    fd
    file
    fluxcd
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
    mc
    nil
    nix-tree
    nixd
    nixfmt-rfc-style
    nixpkgs-fmt
    nnn
    nodejs
    ookla-speedtest
    opentofu
    poetry
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
  ] ++ [
    inputs.agenix.packages."${system}".default
  ];

  catppuccin.flavor = "macchiato";
  catppuccin.fzf.enable = true;
  catppuccin.zellij.enable = true;

  home.shellAliases = {
    c = "code .";
    lg = "lazygit";
    mc = "mc --nosubshell";
    p = "poetry run";
    s = "ssh";
    devv = "nix develop -c zellij -s `basename $PWD` options --default-shell zsh";

    # Since sudo doesn't preserve user PATH,
    # everything installed via nix isn't accessible. This fixes that.
    sudoo = "sudo env \"PATH=$PATH\"";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${npmGlobalDir}/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "gh" "composer" "rsync" ];
    };
    initContent = ''
      ### Fix slowness of pastes with zsh-syntax-highlighting.zsh
      pasteinit() {
        OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
        zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
      }

      pastefinish() {
        zle -N self-insert $OLD_SELF_INSERT
      }
      zstyle :bracketed-paste-magic paste-init pasteinit
      zstyle :bracketed-paste-magic paste-finish pastefinish
      ### Fix slowness of pastes

      # iterm2 integration
      if [ -f $HOME/.iterm2_shell_integration.zsh ]; then
        source $HOME/.iterm2_shell_integration.zsh
      fi

      run() {
        _pkg=$1
        shift
        NIXPKGS_ALLOW_UNFREE=1 nix run --impure "nixpkgs#$_pkg" -- $*
        unset _pkg
      }

      shell() {
        _pkgs=()
        for _pkg in "$@"; do
          _pkgs+=("nixpkgs#$_pkg")
        done
        nix shell "''${_pkgs[@]}"
      }

      # vi mode
      # bindkey -v
    '';
  };

  programs = {
    starship.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    lsd = {
      enable = true;
    };

    neovim = {
      enable = true;
      vimAlias = true;
    };

    broot = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      userName = inputs.self.users."${username}".fullName;
      userEmail = inputs.self.users."${username}".email;
      difftastic.enable = true;
      ignores = [ ".DS_Store" ];
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    lazygit = {
      enable = true;
    };

    tmux = {
      enable = true;
      mouse = true;
      prefix = "C-n";
      terminal = "screen-256color";
      extraConfig = ''
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set -g escape-time 10
      '';
      plugins = [ pkgs.tmuxPlugins.pain-control ];
    };

    zellij = {
      enable = true;
      settings = {
        show_startup_tips = false;
        keybinds = {
          "move" = {
            unbind = { _args = [ "Ctrl h" ]; };
            "bind \"Ctrl m\"" = { SwitchToMode = "Normal"; };
          };
          "shared_except \"move\" \"locked\"" = {
            unbind = { _args = [ "Ctrl h" ]; };
            "bind \"Ctrl m\"" = { SwitchToMode = "Move"; };
          };
          "session" = {
            unbind = { _args = [ "Ctrl o" ]; };
            "bind \"Ctrl u\"" = { SwitchToMode = "Normal"; };
          };
          "shared_except \"session\" \"locked\"" = {
            unbind = { _args = [ "Ctrl o" ]; };
            "bind \"Ctrl u\"" = { SwitchToMode = "Session"; };
          };
        };
      };
      enableZshIntegration = false;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".iterm2_shell_integration.zsh".source = ./config/iterm2_shell_integration.zsh;
  home.file.".npmrc".text = ''
    prefix=${npmGlobalDir}
  '';

  home.file.".local/share/mc/skins/catppuccin.ini".source =
    let
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "mc";
        rev = "f1c78f183764cd43e6dd4e325513ef5547a8f28f";
        sha256 = "sha256-m6MO0Q35YYkTtVqG1v48U7pHcsuPmieDwU2U1ZzQcjo=";
      };
    in
    "${src}/catppuccin.ini";

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "MesloLGSDZ Nerd Font";
      font.size = 18;
      env.TERM = "xterm-256color";
    } // lib.importTOML ./config/alacritty-catppuccin-mocha.toml;
  };
}
