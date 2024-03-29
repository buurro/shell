{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , darwin
    , home-manager
    , flake-utils
    , nixos-hardware
    , nixos-generators
    , disko
    , agenix
    } @ inputs:
    {
      darwinConfigurations = {
        "smart-kettle" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./common/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };

        "smart-toaster" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./common/darwin-configuration.nix
            ./hosts/smart-toaster/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };
      };

      nixosConfigurations = {
        "smart-blender" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/smart-blender/configuration.nix
            disko.nixosModules.disko
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs; };
        };

        "qraspi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/qraspi/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
          specialArgs = { inherit inputs; };
        };

        "smart-kettle" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/smart-kettle/configuration.nix
            nixos-hardware.nixosModules.apple-t2
            disko.nixosModules.disko
          ];
          specialArgs = { inherit inputs; };
        };

        "burro-hp" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/burro-hp/configuration.nix
            disko.nixosModules.disko
          ];
          specialArgs = { inherit inputs; };
        };

        "hyprvm" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/hyprvm/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "ionos-m" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/ionos-m/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

      };

      images = {
        qraspi = (self.nixosConfigurations.qraspi.extendModules {
          modules = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix" ];
        }).config.system.build.sdImage;

        vm = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "vm-nogui";
          modules = [
            ./common/nixos-configuration.nix
            ({ ... }: {
              modules.home-manager.enable = true;
              users.users.marco.initialPassword = "marco";
            })
          ];
          specialArgs = { inherit inputs; };
        };
      };

      users = import ./users.nix;
    };
}
