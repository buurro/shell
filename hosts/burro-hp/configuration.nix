{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${inputs.self}/common/nixos-configuration.nix"
    "${inputs.self}/common/nixos-home-manager.nix"
  ];

  networking.hostName = "burro-hp"; # Define your hostname.

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 3389 ];

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "";
  };
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
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
    packages = with pkgs; [
      chromium
      firefox
      kate
      globalprotect-openconnect
      libreoffice-qt
    ];
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
    lightly-qt
    ocs-url
    qemu
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
