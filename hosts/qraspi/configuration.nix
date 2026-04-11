{...}: {
  networking.hostName = "qraspi";

  modules.adguard-home.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  system.stateVersion = "26.05";
}
