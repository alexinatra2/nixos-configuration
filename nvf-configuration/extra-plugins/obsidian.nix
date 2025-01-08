{ pkgs, ... }:
{
  programs.nvf.settings.vim.extraPlugins = {
    package = pkgs.vimPlugins.obsidian-nvim;
    setup = ''
      require('obsidian').setup {
        workspaces = {
          {
            name = "personal",
            path = "~/opal-overhaul",
          },
        },
      }
    '';
  };
}
