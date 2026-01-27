{
  plugins.lazygit.enable = true;
  plugins.gitsigns.enable = true;
  keymaps = [
    {
      action = "<CMD>LazyGit<CR>";
      key = "<leader>gg";
      options = {
        silent = true;
        desc = "LazyGit";
      };
    }
    {
      action = "<CMD> Gitsigns next_hunk<CR>";
      key = "]h";
      options = {
        silent = true;
        desc = "Next git hunk";
      };
    }
    {
      action = "<CMD> Gitsigns prev_hunk<CR>";
      key = "[h";
      options = {
        silent = true;
        desc = "Previous git hunk";
      };
    }
  ];
}
