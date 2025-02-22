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
    } @ inputs:
    {
      darwinConfigurations = {
        "toaster" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./common/darwin-configuration.nix
            ./hosts/toaster/darwin-configuration.nix
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
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs; };
        };

        "wraspi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/wraspi/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
            agenix.nixosModules.default
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

        "oven" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/oven/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "ionos-m" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/ionos-m/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "mixer" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/mixer/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "k8s-lab" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/k8s-lab/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };

        "github-runner" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/github-runner/configuration.nix
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
        sdImage = ({ lib, ... }: {
          imports = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
          boot.supportedFilesystems.zfs = lib.mkForce false;
        });
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
            ./common/nixos-configuration.nix
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
