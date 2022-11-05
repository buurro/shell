{ config, pkgs, ... }:

let
  unstablePkgs = import <nixpkgs-unstable> { };
in

{
  home.username = "marco";
  home.homeDirectory = "/home/marco";

  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    asciinema
    bat
    bottom
    cachix
    cheat
    docker-compose
    htop
    httpie
    lazygit
    neofetch
    nixpkgs-fmt
    poetry
    ranger
    traceroute
  ];

  home.shellAliases = {
    c = "code .";
    p = "poetry run";
    s = "ssh";
    whatshell = "readlink /proc/$$/exe";

    # Since sudo doesn't preserve user PATH,
    # everything installed via nix isn't accessible. This fixes that.
    sudoo = "sudo env \"PATH=$PATH\"";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" "docker" "composer" ];
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "jessarcher/zsh-artisan"; }
      ];
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

      # on stable neovim is ad 0.7.0. astronvim requires 0.8.0
      package = unstablePkgs.neovim-unwrapped;
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
    };
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".config/nvim".source = ./config/nvim; # astronvim
}
