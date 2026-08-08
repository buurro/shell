{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options = {
    modules.home-manager.enable = lib.mkEnableOption "Home Manager";
  };

  config = lib.mkIf config.modules.home-manager.enable {
    programs.zsh.enable = true;
    # completion is initialized by oh-my-zsh in the user zshrc; the global
    # compinit here would scan fpath a second time on every shell start
    programs.zsh.enableCompletion = false;

    users.users.marco.shell = pkgs.zsh;
    home-manager.users.marco = import ../home-manager/base/default.nix;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };
}
