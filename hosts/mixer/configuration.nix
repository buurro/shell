{ config, inputs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
    ../../common/nixos-minimal-configuration.nix
  ];

  networking.hostName = "mixer";

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "24.11";
}
