{
  plugins.toggleterm = {
    enable = true;

    settings = {
      direction = "float";
      open_mapping = "[[<A-i>]]";
    };
  };

  plugins.flash.enable = true;
  keymaps = [
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = "<CMD>lua require('flash').jump()<CR>";
      options = {
        desc = "Flash jump";
        silent = true;
      };
    }
  ];

  plugins.which-key.enable = true;
}
