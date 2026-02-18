# Host configurations - assembled from aspect modules
{ inputs, ... }:
let
  linuxSystem = "x86_64-linux";
  darwinSystem = "aarch64-darwin";
  linuxUsername = "alexander";
  darwinUsername = "alexanderholzknecht";
  workUsername = "holzknecht@3m5.netz";
in
{
  config = {
    # Host configurations using aspect modules from inputs.self.modules
    # These are auto-collected by import-tree from all feature-*.nix files
    flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      specialArgs = { inherit inputs; };
      modules =
        with inputs.self.modules.nixos;
        [
          nix
          environment
          users
          packages
          locale
          desktop
          bootloader
          virtualisation
          gaming
          stateVersion
        ]
        ++ [ ../hosts/nixos/hardware-configuration.nix ];
    };

    flake.darwinConfigurations."MacBook-Pro-von-Alexander" = inputs.darwin.lib.darwinSystem {
      system = darwinSystem;
      specialArgs = { inherit inputs; };
      modules = with inputs.self.modules.darwin; [
        nix
        environment
        users
        packages
        locale
        darwin-system
      ];
    };

    flake.homeConfigurations."${linuxUsername}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${linuxSystem};
      extraSpecialArgs = {
        inherit inputs;
        username = linuxUsername;
      };
      modules = [
        inputs.nixvim.homeModules.nixvim
      ]
      ++ (with inputs.self.modules.homeManager; [
        nix
        packages
        shell
        git
        firefox
        tmux
        neovim
        opencode
        mcp
        plasma
        kitty
        private
      ]);
    };

    flake.homeConfigurations."${workUsername}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${linuxSystem};
      extraSpecialArgs = {
        inherit inputs;
        username = workUsername;
      };
      modules = [
        inputs.nixvim.homeModules.nixvim
      ]
      ++ (with inputs.self.modules.homeManager; [
        nix
        packages
        shell
        git
        firefox
        tmux
        neovim
        opencode
        mcp
        plasma
        kitty
        work
      ]);
    };

    flake.homeConfigurations."${darwinUsername}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${darwinSystem};
      extraSpecialArgs = {
        inherit inputs;
        username = darwinUsername;
      };
      modules = [
        inputs.nixvim.homeModules.nixvim
      ]
      ++ (with inputs.self.modules.homeManager; [
        nix
        shell
        git
        firefox
        tmux
        neovim
        opencode
        mcp
        kitty
        darwin-home
      ]);
    };
  };
}
