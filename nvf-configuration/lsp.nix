{
  ...
}:
{
  programs.nvf.settings.vim = {
    languages = {
      enableLSP = true;
      enableTreesitter = true;
      enableFormat = true;
      
      nix = {
        enable = true;
        format.type = "nixfmt";
      };
    };

    lsp.mappings = {
      goToDefinition = "gd";
      codeAction = "<M-cr>";
    };
  };
}
