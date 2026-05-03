{ ... }:
{
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>f/" = "live_grep";
      "<leader>fg" = "git_status";
      "<leader>fd" = "diagnostics";
      "<leader>fz" = "current_buffer_fuzzy_find";
      "<leader>fs" = "lsp_document_symbols";
      "<leader>fi" = "builtin";
      "<leader>fh" = "help_tags";
      "<leader>fo" = "oldfiles";
    };
  };
}
