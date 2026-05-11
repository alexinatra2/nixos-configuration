{ self, inputs, ... }:
{
  flake.modules.homeManager.neovim =
    { config, pkgs, ... }:
    let
      nixvimPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim;
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

  perSystem =
    { system, ... }:
    {
      packages.nixvim = inputs.rust-nixvim.packages.${system}.default.extend {
        imports = [
          ../../../nixvim/keymaps.nix
          ../../../nixvim/plugins/oil.nix
          ../../../nixvim/plugins/lazygit.nix
        ];
      };
    };
}
