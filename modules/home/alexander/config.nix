{ self, inputs, ... }:
let
  username = "alexander";
  system = "x86_64-linux";

  hmModules = with self.modules.homeManager; [
    base
    firefox
    fonts
    generations
    git
    comfyui
    mcp
    neovim
    obsidian
    opencode
    pdf
    privatepackages
    shell
    slide-creation
    ssh
    stylix
    tmux
    music-creation
    llms
    sops
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
