{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, vscode-server }:
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

          nixosConfigurations."smart-blender" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/smart-blender/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.marco = import ./common/home.nix;

                # Optionally, use home-manager.extraSpecialArgs to pass
                # arguments to home.nix
              }
              vscode-server.nixosModules.default
              ({ config, pkgs, ... }: {
                services.vscode-server.enable = true;
              })
            ];
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
