{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
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
    in
    {
      # system configurations
      nixosConfigurations = {
        "nixos" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            hostname = "nixos";
            username = "alexander";
            inherit inputs;
          };
          modules = [
            ./configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "alexander" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            username = "alexander";
            inherit inputs;
          };
          modules = [
            ./home.nix
            ./modules/privatepackages.nix
          ];
        };
        "holzknecht@3m5.netz" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            username = "holzknecht@3m5.netz";
            inherit inputs;
          };
          modules = [
            ./home.nix
            ./modules/workpackages.nix
          ];
        };
      };

      packages.${system}.nvf =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [ ./modules/nvf ];
       	})
	.neovim;
  };
}
