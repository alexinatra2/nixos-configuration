{
  keymaps = [
    {
      action = "<CMD>update<CR>";
      key = "<C-s>";
      options = {
        silent = true;
      };
    }
    {
      mode = [ "i" ];
      action = "<C-w>";
      key = "<M-BS>";
      options = {
        silent = true;
      };
    }
    # don't lose previous register content upon pasting
    {
      mode = "x";
      action = "\"_dP";
      key = "<leader>p";
      options = {
        silent = true;
      };
    }
    # don't populate register with deleted content
    {
      mode = [
        "n"
        "v"
      ];
      action = "\"_d";
      key = "<leader>d";
      options = {
        silent = true;
      };
    }
    # move to other windows
    {
      mode = "n";
      key = "<M-h>";
      action = "<C-w>h";
      options = {
        silent = true;
        desc = "Move to left window";
      };
    }
    {
      mode = "n";
      key = "<M-j>";
      action = "<C-w>j";
      options = {
        silent = true;
        desc = "Move to lower window";
      };
    }
    {
      mode = "n";
      key = "<M-k>";
      action = "<C-w>k";
      options = {
        silent = true;
        desc = "Move to upper window";
      };
    }
    {
      mode = "n";
      key = "<M-l>";
      action = "<C-w>l";
      options = {
        silent = true;
        desc = "Move to right window";
      };
    }
  ];
}
