{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    vicinae = {
      url = "github:vicinaehq/vicinae/630036e784de647bcf18aedab7007ec5c4f5b2d0";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions/ca74eede9a778a9373c8f5fd221b0a5026dcd1ef";
    };

    nixvim-config = {
      url = "git+https://codeberg.org/alexinatra/nixvim.git";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    sops-nix.url = "github:Mic92/sops-nix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lore = {
      url = "git+ssh://git@codeberg.org/alexinatra/lore.git";
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
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.wrapper-modules.flakeModules.wrappers
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
