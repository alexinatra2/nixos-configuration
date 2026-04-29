{ ... }:
{
  keymaps = [
    {
      action = "<CMD>update<CR>";
      key = "<C-s>";
      options.silent = true;
    }
    {
      mode = [ "i" ];
      action = "<C-w>";
      key = "<M-BS>";
      options.silent = true;
    }
    {
      mode = "x";
      action = "\"_dP";
      key = "<leader>p";
      options.silent = true;
    }
    {
      mode = [
        "n"
        "v"
      ];
      action = "\"_d";
      key = "<leader>d";
      options.silent = true;
    }
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
    {
      key = "<M-n>";
      action = "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<CR>";
      options = {
        desc = "Next Diagnostic";
        silent = true;
      };
    }
    {
      key = "<M-N>";
      action = "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<CR>";
      options = {
        desc = "Previous Diagnostic";
        silent = true;
      };
    }
    {
      key = "<leader>fw";
      action.__raw = ''
        function()
          local word = vim.fn.expand("<cword>")
          require("telescope.builtin").grep_string({ search = word })
        end
      '';
      options = {
        silent = true;
        desc = "Find word under cursor";
      };
    }
    {
      key = "<leader>fW";
      action.__raw = ''
        function()
          local word = vim.fn.expand("<cWord>")
          require("telescope.builtin").grep_string({ search = word })
        end
      '';
      options = {
        silent = true;
        desc = "Find Word under cursor";
      };
    }
    {
      action = "<CMD>LazyGit<CR>";
      key = "<leader>gg";
      options = {
        silent = true;
        desc = "LazyGit";
      };
    }
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
    {
      key = "<M-e>";
      action = "<cmd>Oil<cr>";
      options.silent = true;
    }
  ];
}
