{
  inputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.nvf
    ./keymaps.nix
    ./lsp.nix
    ./telescope.nix
    ./git.nix
  ];

  programs.nvf.enable = true;

  programs.nvf.settings.vim = {
    viAlias = true;
    vimAlias = true;
    hideSearchHighlight = true;
    treesitter.enable = true;
    theme.enable = true;
    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };
    terminal.toggleterm = {
      enable = true;
      mappings.open = "<A-i>";
      setupOpts.direction = "float";
    };
    binds.whichKey.enable = true;
    options = {
      tabstop = 2;
      shiftwidth = 2;
      autoindent = true;
    };
    utility = {
      smart-splits.enable = true;
      oil-nvim = {
        enable = true;
        gitStatus.enable = true;
      };
      motion.flash-nvim.enable = true;
      undotree.enable = true;
      yanky-nvim = {
        enable = true;
        setupOpts.ring.storage = "memory";
      };
    };
    assistant = {
      copilot = {
        enable = true;
        cmp.enable = true;
      };
      codecompanion-nvim.enable = true;
    };
    ui = {
      borders.enable = true;
      fastaction.enable = true;
      breadcrumbs.enable = true;
    };
    autocomplete.nvim-cmp.enable = true;
  };
}
