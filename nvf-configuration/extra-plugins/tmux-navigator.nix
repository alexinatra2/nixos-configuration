{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."tmux-nvim" = {
    package = pkgs.vimPlugins.tmux-nvim;
    event = [ "BufEnter" ];
  };
}
