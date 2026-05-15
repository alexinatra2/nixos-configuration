{ inputs, ... }:
{
  flake.modules.homeManager.neovim =
    { config, pkgs, ... }:
    let
      nixvimPackage = inputs.nixvim-config.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      home.packages = [
        (nixvimPackage.extend {
          imports = [ config.stylix.targets.nixvim.exportedModule ];
        })
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
