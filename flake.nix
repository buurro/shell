{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        mac-modules = [
          ./common/darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.marco = import ./common/home.nix;
          }
        ];
      in
      {
        packages = {
          darwinConfigurations."smart-kettle" = darwin.lib.darwinSystem {
            inherit system;
            modules = mac-modules;
          };

          darwinConfigurations."smart-toaster" = darwin.lib.darwinSystem {
            inherit system;
            modules = mac-modules ++ [ ./hosts/smart-toaster/darwin-configuration.nix ];
          };

          homeConfigurations.common = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            modules = [
              ./common/home.nix
              ./common/linux-home.nix
            ];
          };
        };
      }
    );
}
