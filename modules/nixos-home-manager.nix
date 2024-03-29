{ config, pkgs, inputs, lib, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options = {
    modules.home-manager.enable = lib.mkEnableOption (lib.mdDoc "Home Manager");
  };

  config = lib.mkIf config.modules.home-manager.enable {
    programs.zsh.enable = true;

    users.users.marco.shell = pkgs.zsh;
    home-manager.users.marco = import ../common/home.nix;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };
}
