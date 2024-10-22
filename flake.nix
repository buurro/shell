{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-2305.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";

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
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
  outputs =
    { self
    , nixpkgs
    , nixpkgs-2305
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

        "unifi" = nixpkgs-2305.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/unifi/configuration.nix
            disko.nixosModules.disko
          ];

          specialArgs = {
            inherit inputs;
            nixpkgs = nixpkgs-2305;
          };
        };

        "ionos-m" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/ionos-m/configuration.nix
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

        live = self.nixosConfigurations.live.config.system.build.isoImage;
      };

      users = import ./users.nix;
    };
}
