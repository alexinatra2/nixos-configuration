{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
    };

    kickstart-nix-nvim = {
      url = "github:alexinatra2/kickstart-nix.nvim";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "alexander";
      mkNixosConfig =
        {
          hostname,
          modules ? [ ./hosts/nixos/configuration.nix ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit hostname;
            inherit username;
          };
          inherit system;
          inherit modules;
        };
      mkHomeConfig =
        {
          username,
          modules ? [ ./home.nix ],
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit username;
            inherit inputs;
          };
          inherit modules;
        };
    in
    rec {
      # system configurations
      nixosConfigurations = {
        nixos = mkNixosConfig {
          hostname = "nixos";
          modules = [
            ./hosts/nixos/configuration.nix
          ];
        };
      };

      # home configurations
      homeConfigurations = {
        "alexander" = mkHomeConfig {
          username = "alexander";
          modules = [
            ./home.nix
          ];
        };
      };

    };
}
