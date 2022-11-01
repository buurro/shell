{ config, pkgs, ... }:

{
  home.username = "marco";
  home.homeDirectory = "/home/marco";

  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    bat
    bottom
    cachix
    git
    httpie
    lazygit
    neofetch
    poetry
    ranger
  ];

  home.shellAliases = {
    c = "code .";
    p = "poetry run";
    s = "ssh";

    # Since sudo doesn't preserve user PATH,
    # everything installed via nix isn't accessible. This fixes that.
    sudo = "sudo env \"PATH=$PATH\"";
  };

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "z" ];
      };
    };

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
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
}
