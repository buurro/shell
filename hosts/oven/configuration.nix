{ pkgs, ... }:
{
  imports = [
    ../../common/nixos-configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "oven";

  environment.systemPackages = with pkgs; [
    chromium
    mpv
    spotify
    vscode.fhs
    jellyfin-media-player
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marco" ];
    };
  };

  modules.hyprland.enable = true;
  modules.home-manager.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "24.05";
}
