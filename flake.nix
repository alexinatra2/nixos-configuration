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

    # Optional, if you intend to follow nvf's obsidian-nvim input
    # you must also add it as a flake input.
    obsidian-nvim = {
      url = "github:epwalsh/obsidian.nvim";
      flake = false;
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
      nvf,
      stylix,
      niri,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "alexander";
      hostname = "nixos";
      mkAppVM = name: {
        type = "app";
        program = "${self.nixosConfiguration.${name}.config.system.build.vm}/bin/run-nixos-vm";
      };
    in
    {
      nixosConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            inherit hostname;
            inherit username;
          };
          modules = [
            ./configuration.nix
            stylix.nixosModules.stylix
            nvf.nixosModules.default
          ];
        };
      };

      # extra vm output for testing
      apps = rec {
        default = vm-test;
        vm-test = mkAppVM "nixos"; # start with `nix run .#apps.vm-test`
      };

      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit username;
            inherit hostname;
          };
          modules = [
            nvf.homeManagerModules.default
            stylix.homeManagerModules.stylix
            ./home.nix
            niri.homeModules.niri
          ];
        };
      };
    };
}
