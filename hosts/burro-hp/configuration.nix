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

  # nix.settings.extra-substituters = [
  #   "https://nix-cache.ambercom.tech?priority=50"
  # ];
  # nix.settings.extra-trusted-public-keys = [
  #   "nix-cache.ambercom.tech:XNEVMOX3/z3PJqILF58XWdVGv91SbJNqZDlcVk3kUtE="
  # ];
  # nix.settings.connect-timeout = 5;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marco = {
    extraGroups = [ "docker" "input" ];
  };

  services.globalprotect.enable = true;

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
    vscode.fhs
    kitty
    dbeaver
    podman-compose
    spotify
  ];

  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
