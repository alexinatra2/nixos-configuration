{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-config = {
      url = "git+https://codeberg.org/alexinatra/nixvim.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    hm-wrapper-modules = {
      url = "github:sini/hm-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    overpass-mcp = {
      url = "git+https://codeberg.org/alexinatra/overpass-mcp.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      hostNames = builtins.attrNames (
        lib.filterAttrs (name: type: type == "directory" && name != "common") (builtins.readDir ./hosts)
      );
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.wrapper-modules.flakeModules.wrappers
        ./homes
      ]
      ++ import ./modules { inherit lib; };

      flake.nixosConfigurations = lib.genAttrs hostNames (
        name:
        lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            self = inputs.self;
          };
          modules = [
            ./hosts/common.nix
            ./hosts/${name}/configuration.nix
          ];
        }
      );
    };
}
