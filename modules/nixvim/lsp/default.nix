{
  lib,
  ...
}:
{
  imports = [
    # intended to configure each server in separate file
    ./nix.nix
    ./ts.nix
    ./rust.nix
    ./kotlin.nix
    ./python.nix
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
