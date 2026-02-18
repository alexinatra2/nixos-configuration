{
  plugins.lazygit.enable = true;
  plugins.gitsigns = {
    enable = true;
    settings = {
      current_line_blame = true;
    };
  };

  keymaps = [
    # lazygit
    {
      action = "<CMD>LazyGit<CR>";
      key = "<leader>gg";
      options = {
        silent = true;
        desc = "LazyGit";
      };
    }

    # gitsigns
    {
      action = "<CMD>Gitsigns next_hunk<CR>";
      key = "]h";
      options = {
        silent = true;
        desc = "Next git hunk [Gitsigns]";
      };
    }
    {
      action = "<CMD>Gitsigns prev_hunk<CR>";
      key = "[h";
      options = {
        silent = true;
        desc = "Previous git hunk [Gitsigns]";
      };
    }
    {
      action = "<CMD>Gitsigns stage_hunk<CR>";
      key = "<leader>gs";
      options = {
        silent = true;
        desc = "Stage git hunk [Gitsigns]";
      };
    }
    {
      action = "<CMD>Gitsigns reset_hunk<CR>";
      key = "<leader>gr";
      options = {
        silent = true;
        desc = "Reset git hunk [Gitsigns]";
      };
    }
    {
      action = "<CMD>Gitsigns reset_buffer<CR>";
      key = "<leader>gR";
      options = {
        silent = true;
        desc = "Reset file [Gitsigns]";
      };
    }
    {
      action = "<CMD>Gitsigns blame<CR>";
      key = "<M-b>";
      options = {
        silent = true;
        desc = "Open blame [Gitsigns]";
      };
    }
    {
      action = "<CMD>Gitsigns toggle_word_diff<CR>";
      key = "<leader>gd";
      options = {
        silent = true;
        desc = "Toggle word diff [Gitsigns]";
      };
    }
  ];
}
