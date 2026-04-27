{ self, inputs, ... }:
let
  configName = "holzknecht";
  username = "holzknecht@3m5.netz";
  system = "x86_64-linux";

  hmModules = with self.modules.homeManager; [
    base
    firefox
    fonts
    generations
    git
    neovim
    opencode
    pdf
    shell
    stylix
    tmux
  ];
in
{
  flake.homeConfigurations.${configName} = inputs.home-manager.lib.homeManagerConfiguration {
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
