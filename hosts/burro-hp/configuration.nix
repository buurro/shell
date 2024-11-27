{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-configuration.nix
    ../../common/nixos-configuration.nix
  ];

  networking.hostName = "burro-hp"; # Define your hostname.

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  networking.wireless.userControlled.enable = true;

  services.openssh.settings.X11Forwarding = true;

  networking.hosts = {
    "127.0.0.1" = [ "localhost.example.com" ];
  };
  # nix.settings.extra-substituters = [
  #   "https://nix-cache.ambercom.tech?priority=50"
  # ];
  # nix.settings.extra-trusted-public-keys = [
  #   "nix-cache.ambercom.tech:XNEVMOX3/z3PJqILF58XWdVGv91SbJNqZDlcVk3kUtE="
  # ];
  # nix.settings.connect-timeout = 5;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marco = {
    extraGroups = [
      "input"
      "libvirtd" # virt-manager
    ];
  };

  # services.globalprotect.enable = true;
  services.upower.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "marco" ];
  };

  environment.systemPackages = with pkgs; [
    chromium
    firefox
    gpclient
    insomnia
    kate
    libreoffice-qt
    lightly-qt
    ocs-url
    qemu
    ruff
    vscode.fhs
    kitty
    spotify
    discord
    vesktop
    dbeaver-bin
    postgresql_16
  ];

  services.flatpak.enable = true;

  virtualisation.docker = {
    enable = true;
  };
  users.extraGroups.docker.members = [ "marco" ];
  # virtualisation.virtualbox.host.enable = true;

  # https://nixos.wiki/wiki/Virt-manager
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  services.ddccontrol.enable = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  modules.home-manager.enable = true;
  modules.hyprland.enable = true;

  system.autoUpgrade.enable = false;

  powerManagement.cpuFreqGovernor = "performance";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
