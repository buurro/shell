{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../common/nixos-configuration.nix
  ];

  modules.home-manager.enable = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "24.05";
}
