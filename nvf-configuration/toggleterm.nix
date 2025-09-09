{ ... }:
{
  programs.nvf.settings.vim.terminal.toggleterm = {
    enable = true;
    mappings = {
      open = "<C-\\>";
    };
    setupOpts = {
      size = 20;
      open_mapping = "<C-\\>";
      hide_numbers = true;
      shade_terminals = true;
      start_in_insert = true;
      insert_mappings = true;
      persist_size = true;
      direction = "float";
      close_on_exit = true;
      shell = "zsh";
      float_opts = {
        border = "curved";
        width = 100;
        height = 30;
        winblend = 3;
      };
    };
    lazygit = {
      enable = true;
      mappings.open = "<leader>gg";
    };
  };
}
