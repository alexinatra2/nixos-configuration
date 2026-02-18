# Host configurations using feature modules
{ inputs, ... }:
let
  # System definitions
  linuxSystem = "x86_64-linux";
  darwinSystem = "aarch64-darwin";

  # Usernames
  linuxUsername = "alexander";
  darwinUsername = "alexanderholzknecht";
  workUsername = "holzknecht@3m5.netz";

  # Import all feature modules
  featureModules = {
    nixos = {
      nix = import ./features/nix.nix { inherit inputs; };
      environment = import ./features/environment.nix { inherit inputs; };
      users = import ./features/users.nix { inherit inputs; };
      packages = import ./features/packages.nix { inherit inputs; };
      locale = import ./features/locale.nix { inherit inputs; };
      desktop = import ./features/desktop.nix { inherit inputs; };
      bootloader = import ./features/bootloader.nix { inherit inputs; };
      virtualisation = import ./features/virtualisation.nix { inherit inputs; };
      gaming = import ./features/gaming.nix { inherit inputs; };
    };
    darwin = {
      nix = import ./features/nix.nix { inherit inputs; };
      environment = import ./features/environment.nix { inherit inputs; };
      users = import ./features/users.nix { inherit inputs; };
      packages = import ./features/packages.nix { inherit inputs; };
      locale = import ./features/locale.nix { inherit inputs; };
      darwin-system = import ./features/darwin-system.nix { inherit inputs; };
    };
    homeManager = {
      nix = import ./features/nix.nix { inherit inputs; };
      packages = import ./features/packages.nix { inherit inputs; };
      shell = import ./features/home-shell.nix { inherit inputs; };
      git = import ./features/home-git.nix { inherit inputs; };
      firefox = import ./features/home-firefox.nix { inherit inputs; };
      tmux = import ./features/home-tmux.nix { inherit inputs; };
      neovim = import ./features/home-neovim.nix { inherit inputs; };
      opencode = import ./features/home-opencode.nix { inherit inputs; };
      mcp = import ./features/home-mcp.nix { inherit inputs; };
      plasma = import ./features/home-plasma.nix { inherit inputs; };
      kitty = import ./features/home-kitty.nix { inherit inputs; };
      private = import ./features/home-private.nix { inherit inputs; };
      work = import ./features/home-work.nix { inherit inputs; };
      darwin-home = import ./features/home-darwin.nix { inherit inputs; };
    };
  };

  # Extract the actual module configuration from flake.modules.* exports
  getNixosModules = names: map (name: featureModules.nixos.${name}.flake.modules.nixos.${name}) names;
  getDarwinModules =
    names: map (name: featureModules.darwin.${name}.flake.modules.darwin.${name}) names;
  getHomeManagerModules =
    names: map (name: featureModules.homeManager.${name}.flake.modules.homeManager.${name}) names;

  # Helper to create NixOS system
  mkNixosSystem =
    {
      hostname,
      system,
      modules,
      specialArgs ? { },
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = modules;
    };

  # Helper to create Darwin system
  mkDarwinSystem =
    {
      hostname,
      system,
      modules,
      specialArgs ? { },
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = modules;
    };

  # Helper to create Home Manager configuration
  mkHomeConfiguration =
    {
      username,
      system,
      modules,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs username; };
      modules = modules;
    };

  # Base modules for NixOS
  nixosBaseModules = getNixosModules [
    "nix"
    "environment"
    "users"
    "packages"
    "locale"
    "desktop"
    "bootloader"
    "virtualisation"
    "gaming"
  ];

  # Base modules for Darwin
  darwinBaseModules = getDarwinModules [
    "nix"
    "environment"
    "users"
    "packages"
    "locale"
    "darwin-system"
  ];

  # Base modules for Home Manager (Linux)
  homeLinuxBaseModules = [
    inputs.nixvim.homeModules.nixvim
  ]
  ++ (getHomeManagerModules [
    "nix"
    "packages"
    "shell"
    "git"
    "firefox"
    "tmux"
    "neovim"
    "opencode"
    "mcp"
    "plasma"
    "kitty"
  ]);

  # Base modules for Home Manager (Darwin)
  homeDarwinBaseModules = [
    inputs.nixvim.homeModules.nixvim
  ]
  ++ (getHomeManagerModules [
    "nix"
    "shell"
    "git"
    "firefox"
    "tmux"
    "neovim"
    "opencode"
    "mcp"
    "kitty"
    "darwin-home"
  ]);
in
{
  flake.nixosConfigurations.nixos = mkNixosSystem {
    hostname = "nixos";
    system = linuxSystem;
    modules = nixosBaseModules ++ [
      ../hosts/nixos/hardware-configuration.nix
    ];
    specialArgs = { inherit inputs; };
  };

  flake.darwinConfigurations."MacBook-Pro-von-Alexander" = mkDarwinSystem {
    hostname = "MacBook-Pro-von-Alexander";
    system = darwinSystem;
    modules = darwinBaseModules;
    specialArgs = { inherit inputs; };
  };

  flake.homeConfigurations."${linuxUsername}" = mkHomeConfiguration {
    username = linuxUsername;
    system = linuxSystem;
    modules = homeLinuxBaseModules ++ [
      featureModules.homeManager.private.flake.modules.homeManager.private
      (
        { ... }:
        {
          home.username = linuxUsername;
          home.homeDirectory = "/home/${linuxUsername}";
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;

          shell = {
            enable = true;
            enableBash = true;
            enableZsh = true;
          };

          firefox = {
            enable = true;
            enabledExtensions = {
              default = true;
              react-development = true;
            };
            defaultSearchEngine = "duckduckgo";
            searchEngines = {
              duckduckgo = true;
              google = true;
              home-manager-options = true;
              nixos-options = true;
            };
          };

          opencode = {
            enable = true;
            agents = {
              build.enable = true;
              explore.enable = true;
              plan.enable = true;
              chat.enable = true;
              creative.enable = true;
              web.enable = true;
            };
          };

          mcp.enable = true;
          neovim.enable = true;
          plasmaOverrides.enable = true;
        }
      )
    ];
  };

  flake.homeConfigurations."${workUsername}" = mkHomeConfiguration {
    username = workUsername;
    system = linuxSystem;
    modules = homeLinuxBaseModules ++ [
      featureModules.homeManager.work.flake.modules.homeManager.work
      (
        { ... }:
        {
          home.username = workUsername;
          home.homeDirectory = "/home/${workUsername}";
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;

          shell = {
            enable = true;
            enableBash = true;
            enableZsh = true;
          };

          firefox = {
            enable = true;
            enabledExtensions = {
              default = true;
              react-development = true;
            };
            defaultSearchEngine = "duckduckgo";
            searchEngines = {
              duckduckgo = true;
              google = true;
              home-manager-options = true;
              nixos-options = true;
            };
          };

          opencode = {
            enable = true;
            agents = {
              build.enable = true;
              explore.enable = true;
              plan.enable = true;
              chat.enable = true;
              creative.enable = true;
              web.enable = true;
            };
          };

          mcp.enable = true;
          neovim.enable = true;
          plasmaOverrides.enable = true;
        }
      )
    ];
  };

  flake.homeConfigurations."${darwinUsername}" = mkHomeConfiguration {
    username = darwinUsername;
    system = darwinSystem;
    modules = homeDarwinBaseModules ++ [
      (
        { ... }:
        {
          home.username = darwinUsername;
          home.homeDirectory = "/Users/${darwinUsername}";
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;

          shell = {
            enable = true;
            enableBash = true;
            enableZsh = true;
          };

          firefox = {
            enable = true;
            enabledExtensions = {
              default = true;
              react-development = true;
            };
            defaultSearchEngine = "duckduckgo";
            searchEngines = {
              duckduckgo = true;
              google = true;
              home-manager-options = true;
              nixos-options = true;
            };
          };

          opencode = {
            enable = true;
            agents = {
              build.enable = true;
              explore.enable = true;
              plan.enable = true;
              chat.enable = true;
              creative.enable = true;
              web.enable = true;
            };
          };

          mcp.enable = true;
          neovim.enable = true;
        }
      )
    ];
  };
}
