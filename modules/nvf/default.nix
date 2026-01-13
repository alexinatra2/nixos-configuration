{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nvf.homeManagerModules.nvf ];

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

    treesitter.enable = true;
    theme.enable = true;
    telescope.enable = true;
    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };
    terminal.toggleterm.enable = true;
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
    };
    languages = {
      nix.enable = true;
      rust.enable = true;
      ts.enable = true;
    };
    ui = {
      borders.enable = true;
      fastaction.enable = true;
      breadcrumbs.enable = true;
    };
    autocomplete.nvim-cmp.enable = true;

    keymaps = [
      {
        key = "<C-S>";
        mode = [
          "i"
          "n"
          "x"
        ];
        action = ":w<CR>";
      }
      {
        key = "<A-BS>";
        mode = "i";
        silent = true;
        action = "<C-w>";
      }
      # telescope
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        desc = "Search text";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        desc = "List buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        desc = "Find help";
      }
      {
        mode = "n";
        key = "<leader>fo";
        action = "<cmd>Telescope oldfiles<CR>";
        desc = "Recent files";
      }
      {
        mode = "n";
        key = "<leader>fk";
        action = "<cmd>Telescope keymaps<CR>";
        desc = "Show keymaps";
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "<cmd>Telescope lsp_document_symbols<CR>";
        desc = "LSP symbols";
      }
      # oil
      {
        key = "<leader>e";
        mode = "n";
        action = ":Oil<CR>";
      }
      # toggleterm
      {
        key = "<A-i>";
        mode = "n";
        action = ":Toggleterm<CR>";
      }
    ];
  };
}
