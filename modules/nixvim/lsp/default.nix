{
  imports = [
    # intended to configure each server in separate file
    ./nix.nix
  ];

  plugins.lsp.enable = true;
  plugins.lsp-format.enable = true;
  lsp.inlayhints.enable = true;
  lsp.keymaps = [
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
  ];
}
