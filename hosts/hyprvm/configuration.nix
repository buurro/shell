{ config, pkgs, inputs, ... }:
{
  imports = [
    "${inputs.self}/common/nixos-configuration.nix"
    "${inputs.self}/common/nixos-home-manager.nix"
    "${inputs.self}/modules/hyprland/default.nix"
  ];

  networking.hostName = "hyprvm";

  virtualisation.vmVariant = {
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display sdl,gl=on,show-cursor=off"
    ];
  };

  system.stateVersion = "23.05";
}
