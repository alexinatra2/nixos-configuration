{
  config.flake.modules.homeManager.vim-telescope = {
    programs.nixvim = {
      plugins.telescope.enable = true;
      # telescope depends on this
      plugins.web-devicons.enable = true;

      plugins.telescope.keymaps = {
        "<leader>ff" = "find_files";
        "<leader><leader>" = "live_grep";
        "<leader>fd" = "diagnostics";
        "<leader>fb" = "lsp_document_symbols";
      };
    };
  };
}
