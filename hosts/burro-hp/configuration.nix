{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-configuration.nix
    "${inputs.self}/common/nixos-configuration.nix"
    "${inputs.self}/common/nixos-home-manager.nix"
    "${inputs.self}/modules/kde.nix"
  ];

  networking.hostName = "burro-hp"; # Define your hostname.

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  services.openssh.settings.X11Forwarding = true;

  nix.settings.extra-substituters = [
    "https://nix-cache.ambercom.tech"
  ];
  nix.settings.extra-trusted-public-keys = [
    "nix-cache.ambercom.tech:XNEVMOX3/z3PJqILF58XWdVGv91SbJNqZDlcVk3kUtE="
  ];
  nix.settings.connect-timeout = 5;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marco = {
    extraGroups = [ "docker" ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "marco" ];

  virtualisation.docker.enable = true;

  services.globalprotect.enable = true;
  services.vscode-server.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "marco" ];
  };

  environment.systemPackages = with pkgs; [
    chromium
    firefox
    globalprotect-openconnect
    kate
    libreoffice-qt
    lightly-qt
    ocs-url
    qemu
    ruff
  ];


  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  boot.loader.grub.theme =
    let
      catppuccin-grub = pkgs.fetchFromGitHub ({
        owner = "catppuccin";
        repo = "grub";
        rev = "803c5df0e83aba61668777bb96d90ab8f6847106";
        hash = "sha256-/bSolCta8GCZ4lP0u5NVqYQ9Y3ZooYCNdTwORNvR7M0=";
      });
    in
    "${catppuccin-grub}/src/catppuccin-macchiato-grub-theme/"
  ;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
