{ inputs, self, ... }:
let
  system = "x86_64-linux";

  mkHome =
    {
      username,
      modules,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        inherit inputs self system username;
      };

      modules = [
        self.modules.homeManager.stylix
      ] ++ modules ++ [
        {
          home = {
            username = username;
            homeDirectory = "/home/${username}";
            stateVersion = "26.05";
          };

          nixpkgs.config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
        }
      ];
    };
in
{
  flake.homeConfigurations.alexander = mkHome {
    username = "alexander";
    modules = [ ./alexander ];
  };
}
