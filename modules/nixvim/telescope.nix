{
  plugins.telescope.enable = true;
  # telescope depends on this
  # Warning during build pointed out to explicitly enable this in config
  plugins.web-devicons.enable = true;

  plugins.telescope.keymaps = {
    "<leader>ff" = "find_files";
    "<leader><leader>" = "live_grep";
    "<leader>fd" = "diagnostics";
    "<leader>fb" = "current_buffer_fuzzy_find";
    "<leader>fq" = "quickfix";
    "<leader>fg" = "git_files";
    "<leader>fh" = "command_history";
    "<leader>fr" = "resume";
    "<leader>fo" = "oldfiles";
    "<leader>fm" = "harpoon marks";
  };
}
