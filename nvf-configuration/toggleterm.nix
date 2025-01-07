{ ... }:
{

  programs.nvf.vim.settings.terminal.toggleterm = {
    enable = true;
    lazygit = {
      enable = true;
      mappings.open = "<leader>g";
    };
  };
}
