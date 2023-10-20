{ config, pkgs, inputs, ... }:
{
  imports = [
    "${inputs.self}/modules/hyprland.nix"
  ];

  networking.hostName = "hyprvm";

  virtualisation.qemu.options = [
    "-device virtio-vga-gl"
    "-display sdl,gl=on,show-cursor=off"
  ];

  system.stateVersion = "23.05";
}
