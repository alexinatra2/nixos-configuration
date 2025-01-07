{ pkgs, ... }:
{
  programs.nvf.settings.vim.extraPlugins = {
    "mini.icons" = {
      package = pkgs.vimPlugins.mini-icons;
    };
    "nvim-web-devicons" = {
      package = pkgs.vimPlugins.nvim-web-devicons;
    };
    "oil.nvim" = {
      package = pkgs.vimPlugins.oil-nvim;
      setup = "require('oil').setup()";
      after = [
        "mini.icons"
        "nvim-web-devicons"
      ];
    };
  };
}
