{
  plugins.oil = {
    enable = true;
    settings = {
      columns = [
        "icon"
        "permissions"
        "size"
      ];
      delete_to_trash = true;
      skip_confirm_for_simple_edits = true;
    };
  };

  plugins.neo-tree = {
    enable = true;
    settings = {
      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = false;
        };
      };
    };
  };

  keymaps = [
    {
      key = "<A-w>";
      action = "<CMD>lua require('oil').toggle_float()<CR>";
      options = {
        desc = "Toggle Oil float";
        silent = true;
      };
    }

    {
      key = "<A-e>";
      action = "<CMD>Neotree filesystem reveal toggle action=show<CR>";
      options = {
        desc = "Toggle Neo‑Tree (reveal current file)";
        silent = true;
      };
    }
  ];
}
