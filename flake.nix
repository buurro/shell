{
  # description = "Marco's darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager }: {
    darwinConfigurations."smart-kettle" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        ./common/darwin-configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.marco = import ./common/home.nix;
        }
      ];
    };
    homeConfigurations.common = home-manager.lib.homeManagerConfiguration {
      modules = [ ./common/home.nix ];
    };
  };
}
