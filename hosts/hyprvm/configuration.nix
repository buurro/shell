{ config, pkgs, inputs, ... }:
{
  imports = [
    "${inputs.self}/common/nixos-configuration.nix"
  ];

  networking.hostName = "hyprvm";

  modules.hyprland.enable = true;
  modules.home-manager.enable = true;

  virtualisation.vmVariant = {
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display sdl,gl=on,show-cursor=off"
    ];
  };

  system.stateVersion = "23.05";
}
