{ config, pkgs, inputs, ... }:
let
  catppuccin = (import "${inputs.self}/packages/catppuccin.nix") {
    inherit pkgs;
    variant = "macchiato";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-configuration.nix
    "${inputs.self}/common/nixos-configuration.nix"
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

  programs.nix-ld.enable = true; # fixes vscode server

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

  boot.loader.grub.theme = catppuccin.grub;

  modules.kde.enable = true;
  modules.home-manager.enable = true;

  services.xserver.displayManager.sddm = {
    settings = {
      General = {
        InputMethod = "";
      };
    };
    theme = toString catppuccin.sddm;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
