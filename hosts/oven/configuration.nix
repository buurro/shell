{ pkgs, inputs, ... }:
{
  imports = [
    ../../common/nixos-configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
    "${inputs.nixos-hardware}/common/gpu/nvidia/ampere"
  ];

  networking.hostName = "oven";

  environment.systemPackages = with pkgs; [
    chromium
    discord
    mpv
    spotify
    vscode.fhs
    jellyfin-media-player
  ];

  security.polkit.enable = true;
  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marco" ];
    };
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "[::]";
    openFirewall = true;
  };

  modules.hyprland.enable = true;
  modules.home-manager.enable = true;

  services.qemuGuest.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "24.11";
}
