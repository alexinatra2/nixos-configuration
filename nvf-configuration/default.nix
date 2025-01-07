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
    ./toggleterm.nix
    ./ui.nix
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

      git.enable = true;

      dashboard.startify = {
        sessionAutoload = true;
        sessionPersistence = true;
      };
    };
  };
}
