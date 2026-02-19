# Host configurations - assembled from aspect modules
{ inputs, ... }:
let
  linuxSystem = "x86_64-linux";
  darwinSystem = "aarch64-darwin";
  linuxUsername = "alexander";
  darwinUsername = "alexanderholzknecht";
  workUsername = "holzknecht@3m5.netz";

  # Vim module - now consolidated in homeManager/vim/default.nix
  vimModule = inputs.self.modules.homeManager.vim;

  # Background image path - resolved relative to this file
  backgroundImagePath = ../background.png;
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
        system
      ];
    };

    flake.homeConfigurations."${linuxUsername}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${linuxSystem};
      extraSpecialArgs = {
        inherit inputs;
        username = linuxUsername;
        backgroundImage = backgroundImagePath;
      };
      modules = [
        {
          home.username = linuxUsername;
          home.homeDirectory = "/home/${linuxUsername}";
          home.stateVersion = "24.11";
        }
      ]
      ++ (with inputs.self.modules.homeManager; [
        nix
        packages
        shell
        git
        firefox
        tmux
        opencode
        mcp
        plasma
        kitty
        private
        stylix
      ])
      ++ [ vimModule ];
    };

    flake.homeConfigurations."${workUsername}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${linuxSystem};
      extraSpecialArgs = {
        inherit inputs;
        username = workUsername;
        backgroundImage = backgroundImagePath;
      };
      modules = [
        {
          home.username = workUsername;
          home.homeDirectory = "/home/${workUsername}";
          home.stateVersion = "24.11";
          plasmaOverrides.keyboard.repeatRate = 250;
        }
      ]
      ++ (with inputs.self.modules.homeManager; [
        nix
        packages
        shell
        git
        firefox
        tmux
        opencode
        mcp
        plasma
        kitty
        work
        stylix
      ])
      ++ [ vimModule ];
    };

    flake.homeConfigurations."${darwinUsername}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${darwinSystem};
      extraSpecialArgs = {
        inherit inputs;
        username = darwinUsername;
        backgroundImage = backgroundImagePath;
      };
      modules = [
        {
          home.username = darwinUsername;
          home.homeDirectory = "/Users/${darwinUsername}";
          home.stateVersion = "24.11";
        }
      ]
      ++ (with inputs.self.modules.homeManager; [
        nix
        shell
        git
        firefox
        tmux
        opencode
        mcp
        kitty
        darwin
        stylix
      ])
      ++ [ vimModule ];
    };
  };
}
