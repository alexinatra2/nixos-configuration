{
  plugins.neo-tree = {
    enable = true;
    settings = {
      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = false;
        };
        use_libuv_file_watcher = true;
      };
    };
  };

  keymaps = [
    # neo-tree
    {
      key = "<A-e>";
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
  ];
}
