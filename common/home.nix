{ config, pkgs, userInfo, inputs, ... }:

{
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
    duf
    file
    fluxcd
    gh
    htop
    httpie
    iftop
    iperf3
    jq
    kubectl
    kubeseal
    lazydocker
    lazygit
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
    rnix-lsp
    sshfs
    wget
    yt-dlp
  ];

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
    enableAutosuggestions = true;
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
        nix run "nixpkgs/${inputs.nixpkgs.rev}#$_pkg" -- $*
        unset _pkg
      }

      shell() {
        _pkgs=()
        for _pkg in "$@"; do
          _pkgs+=("nixpkgs/${inputs.nixpkgs.rev}#$_pkg")
        done
        nix shell "''${_pkgs[@]}"
      }
    '';
  };

  programs = {
    starship.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        "bg+" = "#363a4f";
        "bg" = "#24273a";
        "spinner" = "#f4dbd6";
        "hl" = "#ed8796";
        "fg" = "#cad3f5";
        "header" = "#ed8796";
        "info" = "#c6a0f6";
        "pointer" = "#f4dbd6";
        "marker" = "#f4dbd6";
        "fg+" = "#cad3f5";
        "prompt" = "#c6a0f6";
        "hl+" = "#ed8796";
      };
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
      userName = "Marco Burro";
      userEmail = "marcoburro98@gmail.com";
      difftastic.enable = false;
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    tmux = {
      enable = true;
      mouse = true;
      extraConfig = ''
        set -g default-terminal "xterm-256color"
      '';
      plugins = [ pkgs.tmuxPlugins.pain-control ];
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".config/nvim".source = pkgs.fetchFromGitHub {
    owner = "AstroNvim";
    repo = "AstroNvim";
    rev = "v3.28.3";
    sha256 = "0jzhiyjlnzwvfvqyxzskhy2paf4ys6vfbdyxfd2fm1dbzp6d4a7a";
  };
  home.file.".iterm2_shell_integration.zsh".source = ./config/iterm2_shell_integration.zsh;

  home.file.".local/share/mc/skins/catppuccin.ini".source = let src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "mc";
    rev = "f1c78f183764cd43e6dd4e325513ef5547a8f28f";
    sha256 = "sha256-m6MO0Q35YYkTtVqG1v48U7pHcsuPmieDwU2U1ZzQcjo=";
  }; in "${src}/catppuccin.ini";
}
