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
  ];
}
