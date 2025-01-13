{ pkgs, lib, config, ... }:
let
  catppuccin = (import ../packages/catppuccin.nix) {
    inherit pkgs;
    variant = "mocha";
  };
in
{
  config = lib.mkIf (config.modules.hyprland.enable || config.services.desktopManager.plasma6.enable) {
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        nerd-fonts.meslo-lg
        noto-fonts-cjk-sans
      ];
    };

    # Enable networking
    networking.networkmanager.enable = true;

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

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    catppuccin.flavor = "mocha";

    services.xserver.enable = lib.mkIf (config.modules.hyprland.enable) true;
    services.displayManager.sddm = lib.mkIf (config.modules.hyprland.enable) {
      enable = true;
      settings = {
        General = {
          InputMethod = "";
        };
      };
      theme = toString catppuccin.sddm;
    };

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    catppuccin.grub.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
