{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./keymaps.nix
    ./lsp.nix
    ./telescope.nix
    ./toggleterm.nix
    # ./treesitter.nix
    ./ui.nix
    ./utility.nix
    ./extra-plugins
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;

      useSystemClipboard = true;

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

      extraPackages = with pkgs; [
        cargo
        ripgrep
      ];
    };
  };
}
