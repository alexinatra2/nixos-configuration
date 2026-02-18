# Neovim UI enhancements aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-ui =
    { pkgs, ... }:
    {
      programs.nixvim = {
        # Enable web-devicons for UI icons
        plugins.web-devicons.enable = true;

        plugins.noice.enable = true;
      };
    };
}
