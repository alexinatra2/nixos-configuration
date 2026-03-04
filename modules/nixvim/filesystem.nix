{
  plugins.oil.enable = true;
  keymaps = [
    {
      key = "<M-e>";
      action = "<cmd>Oil<cr>";
      options = {
        silent = true;
      };
    }
  ];
}
