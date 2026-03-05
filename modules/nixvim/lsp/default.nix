{
  imports = [
    ./servers.nix
  ];

  lsp = {
    enable = true;
    inlayHints.enable = true;

    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gD";
        lspBufAction = "references";
      }
      {
        key = "K";
        lspBufAction = "hover";
      }
      {
        key = "<leader>r";
        lspBufAction = "rename";
      }
      {
        key = "<M-CR>";
        lspBufAction = "code_action";
      }
    ];
  };

  plugins.lspconfig.enable = true;
  plugins.lsp-format.enable = true;
}
