{
  programs.nvf.settings.vim.keymaps = [
    {
      key = "<C-S>";
      mode = [
        "i"
        "n"
        "x"
      ];
      action = "<ESC>:w<CR>";
    }
    {
      key = "<A-BS>";
      mode = "i";
      silent = true;
      action = "<C-w>";
    }
    # oil
    {
      key = "<leader>e";
      mode = "n";
      action = ":Oil<CR>";
    }
  ];
}
