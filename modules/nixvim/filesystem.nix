{
  plugins.oil = {
    enable = true;

    settings = {
      default_file_explorer = true;
      columns = [
        "icon"
        "size"
      ];
      skip_confirm_for_simple_edits = true;
    };
  };
  keymaps = [
    {
      key = "<M-e>";
      action = "<CMD>lua require('oil').open_float()<CR>";
      options = {
        silent = true;
      };
    }
  ];
}
