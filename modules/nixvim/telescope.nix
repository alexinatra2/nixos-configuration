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
    # for [d]iagnostics
    "<leader>fd" = "diagnostics";
    # for lsp [s]ymbols
    "<leader>fs" = "lsp_document_symbols";
    # for telescope built[i]ns
    "<leader>fi" = "builtin";
    # for [h]elp tags
    "<leader>fh" = "help_tags";
  };
}
