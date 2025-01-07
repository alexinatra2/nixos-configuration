{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."oil.nvim" = {
    package = pkgs.vimPlugins.oil-nvim;
    cmd = [ "Oil" ];
    event = [ "BufEnter" ];
    keys = [
      {
        key = "-";
        mode = "n";
        silent = true;
        action = ":Oil<cr>";
        desc = "Open Oil";
      }
    ];
  };
}
