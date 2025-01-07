{ ... }:
{

  programs.nvf.settings.vim.terminal.toggleterm = {
    enable = true;
    mappings.open = "<M-t>";
    lazygit = {
      enable = true;
      mappings.open = "<leader>g";
    };
  };
}
