{ self, inputs, ... }:
let
  username = "alexander";
  system = "x86_64-linux";

  hmModules = with self.modules.homeManager; [
    base
    firefox
    generations
    git
    image-editing
    mcp
    neovim
    obsidian
    opencode
    plasmaOverrides
    privatepackages
    shell
    stylix
    tmux
    music-creation
  ];
in
{
  flake.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit username system;
    };

    modules = hmModules;
  };
}
