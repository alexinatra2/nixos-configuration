{ self, inputs, ... }:
let
  username = "alexanderholzknecht";
  system = "aarch64-darwin";

  hmModules = with self.modules.homeManager; [
    base
    firefox
    fonts
    generations
    git
    mcp
    neovim
    obsidian
    opencode
    privatepackages
    shell
    stylix
    tmux
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
