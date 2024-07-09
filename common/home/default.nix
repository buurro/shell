{ pkgs, inputs, config, ... }:

let
  username = config.home.username;
in
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ./programs
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
    bat
    bottom
    cachix
    cheat
    cmctl
    direnv
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
    kubeseal
    lazydocker
    mc
    neofetch
    nil
    nix-tree
    nixpkgs-fmt
    nnn
    nushell
    ookla-speedtest
    opentofu
    poetry
    ranger
    rename
    ripgrep
    sshfs
    tabview
    unzip
    wget
    yt-dlp
  ] ++ [
    inputs.agenix.packages."${system}".default
  ];

  catppuccin.flavor = "mocha";

  home.shellAliases = {
    c = "code .";
    lg = "lazygit";
    mc = "mc --nosubshell";
    p = "poetry run";
    s = "ssh";

    # Since sudo doesn't preserve user PATH,
    # everything installed via nix isn't accessible. This fixes that.
    sudoo = "sudo env \"PATH=$PATH\"";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "gh" "composer" "rsync" ];
    };
    initExtra = ''
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
        NIXPKGS_ALLOW_UNFREE=1 nix run --impure "nixpkgs/${inputs.nixpkgs.rev}#$_pkg" -- $*
        unset _pkg
      }

      shell() {
        _pkgs=()
        for _pkg in "$@"; do
          _pkgs+=("nixpkgs/${inputs.nixpkgs.rev}#$_pkg")
        done
        NIXPKGS_ALLOW_UNFREE=1 nix shell --impure "''${_pkgs[@]}"
      }
    '';
  };

  programs = {
    starship.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      catppuccin.enable = true;
    };

    lsd = {
      enable = true;
      enableAliases = true;
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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".iterm2_shell_integration.zsh".source = ./config/iterm2_shell_integration.zsh;

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
    catppuccin.enable = true;
    settings = {
      font.normal.family = "MesloLGSDZ Nerd Font";
      env.TERM = "xterm-256color";
    };
  };
}
