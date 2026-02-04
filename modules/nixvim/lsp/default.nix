{
  lib,
  ...
}:
{
  imports = [
    ./servers.nix
  ];

  plugins.lsp = {
    enable = true;
    inlayHints = true;
  };

  plugins.lsp-format.enable = true;
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
    {
      key = "<A-CR>";
      lspBufAction = "code_action";
    }
    {
      action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=-1, float=true }) end";
      key = "<A-p>";
    }
    {
      action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=1, float=true }) end";
      key = "<A-n>";
    }
  ];
}
