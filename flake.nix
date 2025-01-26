{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # home-manager, used for managing user configuration
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-tmux-navigator = {
      url = "https://github.com/alexghergh/nvim-tmux-navigation";
      flake = false;
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Required, nvf works best and only directly supports flakes
    nvf = {
      url = "github:notashelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
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
      mkAppVM = name: {
        type = "app";
        program = "${self.nixosConfigurations.${name}.config.system.build.vm}/bin/run-nixos-vm";
      };
    in
    {
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

      # extra vm output for testing
      apps = rec {
        default = nixos-vm;
        nixos-vm = mkAppVM "nixos"; # start with `nix run .#apps.vm-test`
      };
    };
}
