{ ... }:
{
  programs.nvf.settings.vim.telescope = {
    enable = true;
    mappings = {
      findFiles = "<leader>ff";
      liveGrep = "<leader>fg";
      buffers = "<leader>fb";
      helpTags = "<leader>fh";
      open = "<leader>ft";
      gitCommits = "<leader>gc";
      gitBufferCommits = "<leader>gC";
      gitBranches = "<leader>gb";
      gitStatus = "<leader>gs";
      gitStash = "<leader>gx";
    };
    setupOpts = {
      defaults = {
        prompt_prefix = "   ";
        selection_caret = "  ";
        entry_prefix = "  ";
        initial_mode = "insert";
        selection_strategy = "reset";
        sorting_strategy = "ascending";
        layout_strategy = "horizontal";
        layout_config = {
          horizontal = {
            prompt_position = "top";
            preview_width = 0.55;
          };
          vertical = {
            mirror = false;
          };
          width = 0.87;
          height = 0.80;
          preview_cutoff = 120;
        };
        file_ignore_patterns = [
          "node_modules"
          ".git/"
          "*.lock"
        ];
        path_display = [ "truncate" ];
        winblend = 0;
        border = { };
        borderchars = [
          "─"
          "│"
          "─"
          "│"
          "╭"
          "╮"
          "╯"
          "╰"
        ];
        color_devicons = true;
        set_env = {
          COLORTERM = "truecolor";
        };
        file_previewer = "require('telescope.previewers').vim_buffer_cat.new";
        grep_previewer = "require('telescope.previewers').vim_buffer_vimgrep.new";
        qflist_previewer = "require('telescope.previewers').vim_buffer_qflist.new";
      };
      extensions_list = [
        "themes"
        "terms"
      ];
    };
  };
}
