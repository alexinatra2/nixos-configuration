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
      key = "<A-BS>";
      options = {
        silent = true;
      };
    }

    # move to other windows
    {
      mode = "n";
      key = "<A-h>";
      action = "<C-w>h";
      options = {
        silent = true;
        desc = "Move to left window";
      };
    }
    {
      mode = "n";
      key = "<A-j>";
      action = "<C-w>j";
      options = {
        silent = true;
        desc = "Move to lower window";
      };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<C-w>k";
      options = {
        silent = true;
        desc = "Move to upper window";
      };
    }
    {
      mode = "n";
      key = "<A-l>";
      action = "<C-w>l";
      options = {
        silent = true;
        desc = "Move to right window";
      };
    }
  ];
}
