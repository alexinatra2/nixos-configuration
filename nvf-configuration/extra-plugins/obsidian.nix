{ pkgs, ... }:
{
  programs.nvf.settings.vim.extraPlugins."obsidian.nvim" = {
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
