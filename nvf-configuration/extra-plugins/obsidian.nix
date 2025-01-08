{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."obsidian.nvim" = {
    package = pkgs.vimPlugins.obsidian-nvim;
    lazy = true;
    setupModule = "obsidian";
    ft = "markdown";
    setupOpts = {
      workspaces = [
        {
          name = "personal";
          path = "~/opal-overhaul";
        }
      ];
      completion = {
        nvim_cmp = true;
        min_chars = 2;
      };
    };
    keys = [
      {
        key = "<cr>";
        mode = "n";
        silent = true;
        lua = true;
        action = "function() require('obsidian').util.smart_action() end";
        desc = "Perform Obsidian smart action";
      }
    ];
  };
}
