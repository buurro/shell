{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${inputs.self}/common/nixos-configuration.nix"
    "${inputs.self}/common/nixos-home-manager.nix"
    "${inputs.self}/modules/kde.nix"
  ];

  networking.hostName = "burro-hp"; # Define your hostname.

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  services.openssh.settings.X11Forwarding = true;

  nix.settings.substituters = [
    "https://nix-cache.ambercom.tech"
  ];
  nix.settings.trusted-public-keys = [
    "nix-cache.ambercom.tech:XNEVMOX3/z3PJqILF58XWdVGv91SbJNqZDlcVk3kUtE="
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marco = {
    extraGroups = [ "docker" ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "marco" ];

  virtualisation.vmware.host.enable = true;

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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
