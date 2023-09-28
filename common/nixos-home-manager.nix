{ config, pkgs, lib, inputs, ... }:
{
  programs.zsh.enable = true;
  users.users.marco.shell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.marco = import "${inputs.self}/common/home.nix";
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}