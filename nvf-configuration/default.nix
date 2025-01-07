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
    ./keymaps.nix
    ./utility.nix
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
      comments.comment-nvim.enable = true;
      dashboard.dashboard-nvim.enable = true;
    };
  };
}
