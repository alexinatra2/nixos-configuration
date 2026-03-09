{
  plugins.telescope.enable = true;
  # telescope depends on this
  # Warning during build pointed out to explicitly enable this in config
  plugins.web-devicons.enable = true;

  plugins.telescope.keymaps = {
    # for files
    "<leader>ff" = "find_files";
    # / for file search but across multiple files
    "<leader>f/" = "live_grep";
    # select from modified files visible to the git status command
    "<leader>fg" = "git_status";
    # for [d]iagnostics
    "<leader>fd" = "diagnostics";
    # for current buffer fu[z]zy find
    "<leader>fz" = "current_buffer_fuzzy_find";
    # for lsp [s]ymbols
    "<leader>fs" = "lsp_document_symbols";
    # for telescope built[i]ns
    "<leader>fi" = "builtin";
    # for [h]elp tags
    "<leader>fh" = "help_tags";
    # select from [o]ld/previous files only
    "<leader>fo" = "oldfiles";
  };

  keymaps = [
    {
      key = "<leader>gw";
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
  ];
}
