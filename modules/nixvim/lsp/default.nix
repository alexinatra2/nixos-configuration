{
  lib,
  ...
}:
{
  imports = [
    ./servers.nix
    ./lspsaga.nix
  ];

  plugins.lsp = {
    enable = true;
    inlayHints = true;
  };

  plugins.lsp-format.enable = true;
  keymaps = [
    {
      key = "gd";
      action = "<cmd>Lspsaga goto_definition<CR>";
      options = {
        desc = "Goto Definition";
        silent = true;
      };
    }
    {
      key = "gD";
      action = "<cmd>Lspsaga finder ref<CR>";
      options = {
        desc = "Goto References";
        silent = true;
      };
    }
    {
      key = "K";
      action = "<cmd>Lspsaga hover_doc<CR>";
      options = {
        desc = "Hover";
        silent = true;
      };
    }
    {
      key = "<leader>r";
      action = "<cmd>Lspsaga rename<CR>";
      options = {
        desc = "Rename";
        silent = true;
      };
    }
    {
      key = "<A-n>";
      action = "<cmd>Lspsaga diagnostic_jump_next<CR>";
      options = {
        desc = "Next Diagnostic";
        silent = true;
      };
    }
    {
      key = "<A-N>";
      action = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
      options = {
        desc = "Previous Diagnostic";
        silent = true;
      };
    }
    {
      key = "<A-CR>";
      action = "<cmd>Lspsaga code_action<CR>";
      options = {
        desc = "Previous Diagnostic";
        silent = true;
      };
    }
    {
      key = "<A-o>";
      action = "<cmd>Lspsaga outline<CR>";
      options = {
        desc = "Outline";
        silent = true;
      };
    }
  ];
}
