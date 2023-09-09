{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , darwin
    , home-manager
    , flake-utils
    , vscode-server
    , nixos-hardware
    , nixos-generators
    }:
    let
      homeManagerConfig = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.marco = import ./common/home.nix;
      };
    in
    {
      darwinConfigurations = {
        "smart-kettle" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./common/darwin-configuration.nix
            homeManagerConfig
            home-manager.darwinModules.home-manager
          ];
        };

        "smart-toaster" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./common/darwin-configuration.nix
            ./hosts/smart-toaster/darwin-configuration.nix
            homeManagerConfig
            home-manager.darwinModules.home-manager
          ];
        };
      };

      nixosConfigurations = {
        "smart-blender" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/nixos-configuration.nix
            ./hosts/smart-blender/configuration.nix
            vscode-server.nixosModules.default
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };

        "qraspi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./common/nixos-configuration.nix
            ./hosts/qraspi/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };

        "burro-hp" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/nixos-configuration.nix
            ./hosts/burro-hp/configuration.nix
            vscode-server.nixosModules.default
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };
      };

      images = {
        qraspi = (self.nixosConfigurations.qraspi.extendModules {
          modules = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix" ];
        }).config.system.build.sdImage;

        vbox = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "virtualbox";
          modules = [
            ./common/nixos-configuration.nix
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };

        vm = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "vm-nogui";
          modules = [
            ./common/nixos-configuration.nix
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };
      };
    };
}
