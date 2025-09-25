{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."gitsigns.nvim" = {
    package = pkgs.vimPlugins.gitsigns-nvim;
    event = [
      "BufRead"
      "BufNewFile"
    ];
    setupModule = "gitsigns";
    setupOpts = {
      signs = {
        add = {
          text = "│";
        };
        change = {
          text = "│";
        };
        delete = {
          text = "_";
        };
        topdelete = {
          text = "‾";
        };
        changedelete = {
          text = "~";
        };
        untracked = {
          text = "┆";
        };
      };
      signcolumn = true;
      numhl = false;
      linehl = false;
      word_diff = false;
      watch_gitdir = {
        follow_files = true;
      };
      attach_to_untracked = true;
      current_line_blame = true;
      current_line_blame_opts = {
        virt_text = true;
        virt_text_pos = "eol";
        delay = 1000;
        ignore_whitespace = false;
      };
      sign_priority = 6;
      update_debounce = 100;
      status_formatter = null;
      max_file_length = 40000;
      preview_config = {
        border = "single";
        style = "minimal";
        relative = "cursor";
        row = 0;
        col = 1;
      };
    };
    keys = [
      {
        key = "]c";
        mode = "n";
        silent = true;
        action = ":Gitsigns next_hunk<cr>";
        desc = "Next git hunk";
      }
      {
        key = "[c";
        mode = "n";
        silent = true;
        action = ":Gitsigns prev_hunk<cr>";
        desc = "Previous git hunk";
      }
      {
        key = "<leader>hs";
        mode = "n";
        silent = true;
        action = ":Gitsigns stage_hunk<cr>";
        desc = "Stage git hunk";
      }
      {
        key = "<leader>hr";
        mode = "n";
        silent = true;
        action = ":Gitsigns reset_hunk<cr>";
        desc = "Reset git hunk";
      }
      {
        key = "<leader>hS";
        mode = "n";
        silent = true;
        action = ":Gitsigns stage_buffer<cr>";
        desc = "Stage entire buffer";
      }
      {
        key = "<leader>hu";
        mode = "n";
        silent = true;
        action = ":Gitsigns undo_stage_hunk<cr>";
        desc = "Undo stage hunk";
      }
      {
        key = "<leader>hR";
        mode = "n";
        silent = true;
        action = ":Gitsigns reset_buffer<cr>";
        desc = "Reset entire buffer";
      }
      {
        key = "<leader>hp";
        mode = "n";
        silent = true;
        action = ":Gitsigns preview_hunk<cr>";
        desc = "Preview git hunk";
      }
      {
        key = "<leader>hb";
        mode = "n";
        silent = true;
        lua = true;
        action = "function() require('gitsigns').blame_line{full=true} end";
        desc = "Show git blame";
      }
      {
        key = "<leader>tb";
        mode = "n";
        silent = true;
        action = ":Gitsigns toggle_current_line_blame<cr>";
        desc = "Toggle git blame";
      }
      {
        key = "<leader>hd";
        mode = "n";
        silent = true;
        action = ":Gitsigns diffthis<cr>";
        desc = "Show git diff";
      }
    ];
  };
}
