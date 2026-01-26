{
  plugins.lazygit.enable = true;
  plugins.gitsigns.enable = true;
  keymaps = [
    {
      action = "<cmd>LazyGit<CR>";
      key = "<leader>gg";
      options = {
        silent = true;
      };
    }
  ];
}
