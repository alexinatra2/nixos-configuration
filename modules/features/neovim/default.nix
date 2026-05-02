{ self, inputs, ... }:
{
  flake.modules.homeManager.neovim =
    { config, pkgs, ... }:
    let
      nixvimPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim;
    in
    {
      home.packages = [ (nixvimPackage.extend config.stylix.targets.nixvim.exportedModule) ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

  perSystem =
    { system, pkgs, ... }:
    {
      packages.nixvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = ../../../nixvim;
      };
    };
}
