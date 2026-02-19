# Neovim base configuration - enables nixvim and imports the nixvim module
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-base =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        extraPackages = with pkgs; [ lsof ];
      };
    };
}
