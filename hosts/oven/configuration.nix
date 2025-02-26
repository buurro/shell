{ pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    # broken
    # "${inputs.nixos-hardware}/common/gpu/nvidia/ampere"
  ];

  networking.hostName = "oven";

  environment.systemPackages = with pkgs; [
    chromium
    discord
    mpv
    nvtopPackages.nvidia
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

  networking.firewall.allowedTCPPorts = [
    80
    5678
  ];

  virtualisation.oci-containers.containers = {
    cheshire_cat_core = {
      image = "ghcr.io/cheshire-cat-ai/core:1.7.1";
      extraOptions = [ "--network=host" ];
      volumes = [
        "cheshire_cat_static:/app/cat/static"
        "cheshire_cat_plugins:/app/cat/plugins"
        "cheshire_cat_data:/app/cat/data"
      ];
    };
  };

  modules.hyprland.enable = true;
  modules.home-manager.enable = true;

  services.qemuGuest.enable = true;
  fileSystems."/".autoResize = true;

  powerManagement.cpuFreqGovernor = "performance";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "24.11";
}
