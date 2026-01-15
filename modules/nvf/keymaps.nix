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
    # toggleterm
    {
      key = "<A-i>";
      mode = "n";
      action = ":Toggleterm<CR>";
    }
    # yanky-nvim
    {
      key = "p";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyPutAfter)";
    }
    {
      key = "P";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyPutBefore)";
    }
    {
      key = "gp";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyGPutAfter)";
    }
    {
      key = "gP";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyGPutBefore)";
    }
    {
      key = "<C-p>";
      mode = "n";
      action = "<Plug>(YankyPreviousEntry)";
    }
    {
      key = "<C-n>";
      mode = "n";
      action = "<Plug>(YankyNextEntry)";
    }
  ];
}
