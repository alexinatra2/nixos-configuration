{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."nvim-tree.lua" = {
    package = pkgs.vimPlugins.nvim-tree-lua;
    lazy = false;
    setupModule = "nvim-tree";
    setupOpts = {
      disable_netrw = true;
      hijack_netrw = true;
      view = {
        width = 35;
        side = "left";
      };
      renderer = {
        group_empty = true;
        icons = {
          show = {
            file = true;
            folder = true;
            folder_arrow = true;
            git = true;
          };
        };
      };
      filters = {
        dotfiles = false;
        custom = [
          ".git"
          "node_modules"
          ".cache"
        ];
      };
      git = {
        enable = true;
        ignore = false;
      };
      actions = {
        open_file = {
          resize_window = true;
        };
      };
    };
    keys = [
      {
        key = "<C-n>";
        mode = "n";
        silent = true;
        action = ":NvimTreeToggle<cr>";
        desc = "Toggle file explorer";
      }
      {
        key = "<leader>e";
        mode = "n";
        silent = true;
        action = ":NvimTreeFocus<cr>";
        desc = "Focus file explorer";
      }
    ];
  };
}
