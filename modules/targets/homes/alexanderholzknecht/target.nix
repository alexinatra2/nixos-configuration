{ self, inputs, ... }:
let
  profileName = "alexanderholzknecht";
  username = "alexanderholzknecht";
  system = "aarch64-darwin";
in
{
  flake.homeConfigurations.${profileName} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit username system;
    };

    modules = [ self.modules.homeManager.${profileName} ];
  };
}
