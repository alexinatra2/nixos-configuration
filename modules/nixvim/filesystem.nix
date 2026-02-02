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

  plugins.harpoon = {
    enable = true;
    enableTelescope = true;
  };

  keymaps = [
    # oil
    {
      key = "<A-d>";
      action = "<CMD>lua require('oil').toggle_float()<CR>";
      options = {
        desc = "Toggle Oil float [Oil]";
        silent = true;
      };
    }

    # neo-tree
    {
      key = "<A-f>";
      action = "<CMD>Neotree filesystem reveal toggle action=show<CR>";
      options = {
        desc = "Toggle Neotree [Neotree]";
        silent = true;
      };
    }
    {
      key = "<A-g>";
      action = "<CMD>Neotree source=git_status reveal toggle action=show<CR>";
      options = {
        desc = "Toggle Neotree (showing git files) [Neotree]";
        silent = true;
      };
    }

    # TODO harpoon
  ];
}
