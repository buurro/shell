{ config, pkgs, userInfo, ... }:

{
  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ];
    trusted-substituters = [
      "https://cache.nixos.org"
      "https://cache.nixos.org/"
      "https://nix-shell.cachix.org"
      "https://buurro.cachix.org"
      "https://nixpkgs-python.cachix.org"
      "https://fossar.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-shell.cachix.org-1:kat3KoRVbilxA6TkXEtTN9IfD4JhsQp1TPUHg652Mwc="
      "buurro.cachix.org-1:1MX3Bpgo3DanuGkHjTscCkBvNKBa2Qk1BqvP0P+rqk0="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      "fossar.cachix.org-1:Zv6FuqIboeHPWQS7ysLCJ7UT7xExb4OE8c4LyGb5AsE="
    ];
    trusted-users = [
      "root"
      "marco"
    ];
  };

  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    ansible
    ansible-lint
    argocd
    asciinema
    bat
    bottom
    cachix
    cheat
    cmctl
    duf
    file
    gh
    htop
    httpie
    iperf3
    jq
    kubectl
    kubeseal
    lazydocker
    lazygit
    neofetch
    nixpkgs-fmt
    poetry
    ranger
    rename
    rnix-lsp
    ruff
    sshfs
    terraform
    wget
    yt-dlp

    nodejs-18_x
  ];

  home.shellAliases = {
    c = "code .";
    lg = "lazygit";
    p = "poetry run";
    s = "ssh";

    # Since sudo doesn't preserve user PATH,
    # everything installed via nix isn't accessible. This fixes that.
    sudoo = "sudo env \"PATH=$PATH\"";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    # YSU_IGNORED_ALIASES = "(\"g\")";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "gh" "z" "docker" "composer" "vagrant" "rust" "rsync" ];
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
        nix run "nixpkgs/23.05#$_pkg" -- $*
        unset _pkg
      }

      shell() {
        nix shell "nixpkgs/23.05#$1"
      }
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
      extraConfig = ''
        set -g default-terminal "xterm-256color"
      '';
    };
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".config/nvim".source = pkgs.fetchFromGitHub
    {
      owner = "AstroNvim";
      repo = "AstroNvim";
      rev = "v3.28.3";
      sha256 = "0jzhiyjlnzwvfvqyxzskhy2paf4ys6vfbdyxfd2fm1dbzp6d4a7a";
    };
}
