{ self, inputs, ... }:
let
  profileName = "alexander";
  username = "alexander";
  system = "x86_64-linux";
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
