# Neovim UI enhancements aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-ui =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins.noice.enable = true;
      };
    };
}
