# Host configurations - assembled from aspect modules
{ inputs, ... }:
let
  # Vim aspect modules - organized by feature
  vimAspects = with inputs.self.modules.homeManager; [
    vim-base
    vim-options
    vim-keymaps
    vim-completion
    vim-lsp
    vim-lspsaga
    vim-servers
    vim-telescope
    vim-treesitter
    vim-git
    vim-filesystem
    vim-utility
    vim-ai
    vim-ui
  ];

  # Background image path - resolved relative to this file
  backgroundImagePath = ../background.png;
in
{
  config = {
    flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules =
        with inputs.self.modules.nixos;
        [
          nix
          nh
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
      system = "aarch64-darwin";
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

    flake.homeConfigurations = {
      "alexander" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          username = "alexander";
        };
        modules =
          (with inputs.self.modules.homeManager; [
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
          ++ vimAspects;
      };

    };

    "holzknecht@3m5.netz" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {
        inherit inputs;
        username = "holzknecht@3m5.netz";
      };
      modules =
        (with inputs.self.modules.homeManager; [
          nix
          nh
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
        ++ vimAspects;
    };

    "alexanderholzknecht" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      extraSpecialArgs = {
        inherit inputs;
        username = "alexanderholzknecht";
      };
      modules =
        (with inputs.self.modules.homeManager; [
          nix
          shell
          git
          firefox
          tmux
          opencode
          mcp
          kitty
          darwin-home
          stylix
        ])
        ++ vimAspects;
    };
  };
}
