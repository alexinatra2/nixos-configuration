{ self, inputs, ... }:
{
  flake.modules.homeManager.neovim = {
    imports = [ inputs.nixvim.homeModules.nixvim ];

    programs.nixvim = {
      enable = true;
      imports = [
        ./_config/core.nix
        ./_config/keymaps.nix
        ./_config/plugins.nix
        ./_config/lsp.nix
      ];
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
