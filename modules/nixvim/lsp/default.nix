{
  imports = [
    ./servers.nix
  ];

  plugins.lsp = {
    enable = true;
    inlayHints = true;
  };

  plugins.lsp-format.enable = true;
  keymaps =
    let
      mkLspAction = bufAction: "<cmd>lua vim.lsp.buf.${bufAction}()<cr>";
    in
    [
      {
        key = "gd";
        action = mkLspAction "definition";
        options = {
          desc = "Goto Definition";
          silent = true;
        };
      }
      {
        key = "gR";
        action = mkLspAction "references";
        options = {
          desc = "Goto References";
          silent = true;
        };
      }
      {
        key = "K";
        action = mkLspAction "hover";
        options = {
          desc = "Hover";
          silent = true;
        };
      }
      {
        key = "<leader>r";
        action = mkLspAction "rename";
        options = {
          desc = "Rename";
          silent = true;
        };
      }
      {
        key = "<M-CR>";
        action = mkLspAction "code_action";
        options = {
          desc = "Code action";
          silent = true;
        };
      }
    ];
}
