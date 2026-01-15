{
  inputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.nvf
    ./keymaps.nix
    ./telescope.nix
  ];

  programs.nvf.enable = true;

  programs.nvf.settings.vim = {
    viAlias = true;
    vimAlias = true;
    lsp = {
      enable = true;
      formatOnSave = true;
      inlayHints.enable = true;
      mappings = {
        codeAction = "<A-CR>";
        goToDefinition = "gd";
        nextDiagnostic = "<A-n>";
        previousDiagnostic = "<A-p>";
        renameSymbol = "<A-r>";
      };
    };
    languages = {
      nix.enable = true;
      rust.enable = true;
      ts = {
        enable = true;
        extraDiagnostics.enable = true;
        format.enable = true;
      };
    };

    git.enable = true;
    treesitter.enable = true;
    theme.enable = true;
    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };
    terminal.toggleterm = {
      enable = true;
      mappings.open = "<A-t>";
      setupOpts.direction = "float";
      lazygit.enable = true;
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
      yanky-nvim = {
        enable = true;
        setupOpts.ring.storage = "memory";
      };
    };
    ui = {
      borders.enable = true;
      fastaction.enable = true;
      breadcrumbs.enable = true;
    };
    autocomplete.nvim-cmp.enable = true;
  };
}
