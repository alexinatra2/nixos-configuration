{
  description = "Multi-platform system configurations (NixOS + Darwin)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      mkHome =
        {
          username,
          system,
          modules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = forAllSystems.${system};
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./modules/home.nix ] ++ modules;
        };

    in
    {
      # --- NixOS hosts ---
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostname = "nixos";
            username = "alexander";
          };
          modules = [
            ./hosts/nixos/configuration.nix
            ./modules/common.nix
          ];
        };
      };

      # --- macOS hosts ---
      darwinConfigurations = {
        "MacBook-Pro-von-Alexander" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs;
            hostname = "MacBook-Pro-von-Alexander";
            username = "alexanderholzknecht";
          };
          modules = [
            ./hosts/macbook/darwin-configuration.nix
          ];
        };
      };

      # --- user-level configurations (standalone Home Manager) ---
      homeConfigurations = {
        "alexander" = mkHome {
          username = "alexander";
          system = "x86_64-linux";
          modules = [
            ./modules/privatepackages.nix
            ./home/niri
          ];
        };

        "holzknecht@3m5.netz" = mkHome {
          username = "holzknecht@3m5.netz";
          system = "x86_64-linux";
          modules = [
            ./modules/workpackages.nix
          ];
        };
        "alexanderholzknecht" = mkHome {
          username = "alexanderholzknecht";
          system = "aarch64-darwin";
          modules = [ ./modules/darwin-home.nix ];
        };
      };
    };
}
