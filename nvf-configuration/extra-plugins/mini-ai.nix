{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."mini.ai" = {
    package = pkgs.vimPlugins.mini-ai;
    event = [ "BufEnter" ];
  };
}
