{
  programs.nvf.settings.vim = {
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
      nix = {
        enable = true;
        extraDiagnostics.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      rust.enable = true;
      ts = {
        enable = true;
        extraDiagnostics.enable = true;
        format.enable = true;
      };
      python.enable = true;
      bash.enable = true;
      kotlin.enable = true;
    };
  };
}
