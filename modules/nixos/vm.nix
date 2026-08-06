# Scaffolding shared by the local qemu VMs (swayvm, headlessvm). They only
# ever exist as `.vmVariant` — `nix run .#<name>` — so the disk and bootloader
# config below is a stub that just keeps the non-vm system evaluating.
{inputs, ...}: {
  modules.home-manager.enable = true;
  home-manager.backupFileExtension = "bak";

  # the minimal profile ships almost no terminfo; alacritty's own comes
  # with the package, this covers root shells and anything ssh'ing in
  environment.enableAllTerminfo = true;

  system.autoUpgrade.enable = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.systemd-boot.enable = true;

  virtualisation.vmVariant = {
    virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    users.users.marco.initialPassword = "marco";
  };

  system.stateVersion = "25.11";
}
