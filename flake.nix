{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.45.2";
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
    , catppuccin
    , hyprland
    , nixvim
    } @ inputs:
    {
      darwinConfigurations = {
        "toaster" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            self.darwinModules.default
            home-manager.darwinModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };
        "heater" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/heater/configuration.nix
            self.darwinModules.default
            self.darwinModules.work
            home-manager.darwinModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };
        "lamp" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/lamp/configuration.nix
            self.darwinModules.default
            self.darwinModules.work
            home-manager.darwinModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };

      };

      nixosConfigurations = {
        "blender" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/blender/configuration.nix
            self.nixosModules.default
            disko.nixosModules.disko
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs; };
        };

        "qraspi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/qraspi/configuration.nix
            self.nixosModules.default
            nixos-hardware.nixosModules.raspberry-pi-4
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs; };
        };

        "wraspi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/wraspi/configuration.nix
            self.nixosModules.default
            nixos-hardware.nixosModules.raspberry-pi-4
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs; };
        };

        "ionos-m" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.default
            ./hosts/ionos-m/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "mixer" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.minimal
            ./hosts/mixer/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "k8s-lab" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.minimal
            ./hosts/k8s-lab/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "github-runner" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.minimal
            ./hosts/github-runner/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "fridge" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.minimal
            ./hosts/fridge/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "db-1" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.minimal
            ./hosts/db-1/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "wooper" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.default
            ./hosts/wooper/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "live" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            {
              users.users.root.openssh.authorizedKeys.keys = self.users.marco.ssh.publicKeys;
            }
          ];
          # specialArgs = { inherit inputs; };
        };
      };

      nixosModules = {
        default = ./modules/nixos/base/default.nix;
        minimal = ./modules/nixos/base/minimal.nix;
        sdImage = ({ lib, ... }: {
          imports = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
          boot.supportedFilesystems.zfs = lib.mkForce false;
        });
      };

      darwinModules = {
        default = ./modules/darwin/base/default.nix;
        work = ./modules/darwin/work/default.nix;
      };

      images = {
        qraspi = (self.nixosConfigurations.qraspi.extendModules {
          modules = [ self.nixosModules.sdImage ];
        }).config.system.build.sdImage;

        wraspi = (self.nixosConfigurations.wraspi.extendModules {
          modules = [ self.nixosModules.sdImage ];
        }).config.system.build.sdImage;

        vm = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "vm-nogui";
          modules = [
            self.nixosModules.default
            ({ ... }: {
              modules.home-manager.enable = true;
              users.users.marco.initialPassword = "marco";
            })
          ];
          specialArgs = { inherit inputs; };
        };

        live = self.nixosConfigurations.live.config.system.build.isoImage;
      };

      users = import ./users.nix;
    } // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    });
}
