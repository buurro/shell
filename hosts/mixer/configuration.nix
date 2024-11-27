{ config, inputs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
    ../../common/nixos-minimal-configuration.nix
  ];

  networking.hostName = "mixer";


  age.secrets."mixer-vpn-conf" = {
    file = ../../secrets/mixer-vpn-conf.age;
  };

  networking.wg-quick.interfaces.wg0.configFile = config.age.secrets."mixer-vpn-conf".path;

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
