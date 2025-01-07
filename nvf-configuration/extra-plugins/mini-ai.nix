{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins.harpoon = {
    package = pkgs.vimPlugins.mini-ai;
    event = [ "BufEnter" ];
  };
}
