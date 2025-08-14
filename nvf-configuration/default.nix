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

      preventJunkFiles = true;
      undoFile.enable = true;
      searchCase = "smart";

      options = {
        autoindent = true;
        mouse = "a";
        shiftwidth = 2;
        tabstop = 2;
      };

      statusline.lualine.enable = true;
      binds.whichKey.enable = true;
      autocomplete.nvim-cmp.enable = true;

      git.enable = true;
      comments.comment-nvim.enable = true;
      dashboard.dashboard-nvim.enable = true;

      extraPackages = with pkgs; [
        cargo
        rustc
        rustfmt
        ripgrep
      ];

      assistant.copilot = {
        enable = true;
        cmp.enable = true;
      };
    };
  };
}
