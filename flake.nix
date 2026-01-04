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
      hostname = "nixos";
    in
    rec {
      # system configurations
      nixosConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit hostname;
            inherit username;
          };
          inherit system;
          modules = [
            ./hosts/nixos/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit username;
            inherit inputs;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
