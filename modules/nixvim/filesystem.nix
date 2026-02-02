{
  plugins.oil.enable = true;
  plugins.neo-tree = {
    enable = true;
    settings = {
      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = false;
        };
      };
      window = {
        auto_focus = false;
      };
    };
  };

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Oil<CR>";
      options = {
        silent = true;
      };
    }

    {
      key = "<A-e>";
      action = "<CMD>Neotree filesystem reveal toggle<CR>";
      options = {
        desc = "Toggle Neo‑Tree (reveal current file)";
        silent = true;
      };
    }
  ];
}
