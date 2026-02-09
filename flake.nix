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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      linuxPkgs = nixpkgs.legacyPackages.${linuxSystem};
      darwinPkgs = nixpkgs.legacyPackages.${darwinSystem};
    in
    {
      # system configurations
      nixosConfigurations = {
        "nixos" = nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          specialArgs = {
            hostname = "nixos";
            username = "alexander";
            inherit inputs;
          };
          modules = [ ./configuration.nix ];
        };

        # Graphical Plasma 6 installer ISO
        "iso" = nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          specialArgs = {
            hostname = "nixos-installer";
            username = "alexander";
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
            {
              isoImage.makeEfiBootable = true;
              isoImage.makeUsbBootable = true;
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              networking.hostName = "nixos-installer";
            }
          ];
        };
      };

      # ISO build target
      packages.${linuxSystem}.iso = self.nixosConfigurations.iso.config.system.build.isoImage;

      homeConfigurations = {
        "alexander" = home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
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
          pkgs = linuxPkgs;
          extraSpecialArgs = {
            username = "holzknecht@3m5.netz";
            inherit inputs;
          };
          modules = [
            ./home.nix
            ./modules/workpackages.nix
          ];
        };
        "alexanderholzknecht" = home-manager.lib.homeManagerConfiguration {
          pkgs = darwinPkgs;
          extraSpecialArgs = {
            username = "alexanderholzknecht";
            inherit inputs;
          };
          modules = [
            ./home-darwin.nix
          ];
        };
      };

    };
}
