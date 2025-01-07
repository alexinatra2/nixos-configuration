{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins.harpoon = {
    package = pkgs.vimPlugins.harpoon;
    event = [ "BufEnter" ];
    keys = [
      {
        key = "<leader>a";
        mode = "n";
        silent = true;
        action = ":lua require('harpoon.mark').add_file()<cr>";
        desc = "Add harpoon file";
      }
      {
        key = "<leader>s";
        mode = "n";
        silent = true;
        action = ":lua require('harpoon.ui').toggle_quick_menu()<cr>";
        desc = "Show harpoon files";
      }
      {
        key = "<leader>1";
        mode = "n";
        silent = true;
        action = ":lua require('harpoon.ui').nav_file(1)<cr>";
        desc = "Navigate to harpoon file 1";
      }
      {
        key = "<leader>2";
        mode = "n";
        silent = true;
        action = ":lua require('harpoon.ui').nav_file(2)<cr>";
        desc = "Navigate to harpoon file 2";
      }
      {
        key = "<leader>3";
        mode = "n";
        silent = true;
        action = ":lua require('harpoon.ui').nav_file(3)<cr>";
        desc = "Navigate to harpoon file 3";
      }
      {
        key = "<leader>4";
        mode = "n";
        silent = true;
        action = ":lua require('harpoon.ui').nav_file(4)<cr>";
        desc = "Navigate to harpoon file 4";
      }
    ];
  };
}
