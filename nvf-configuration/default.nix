{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./lsp.nix
    ./telescope.nix
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;

      theme = {
        enable = true;
        name = "gruvbox";
        style = "dark";
      };

      statusline.lualine.enable = true;
      binds.whichKey.enable = true;
      autocomplete.nvim-cmp.enable = true;
      terminal.toggleterm = {
        enable = true;
        lazygit.enable = true;
      };
    };
  };
}
