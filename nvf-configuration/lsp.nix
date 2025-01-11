{
  programs.nvf.settings.vim = {
    languages = {
      enableLSP = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;
      enableFormat = true;

      # enabled languages
      nix = {
        enable = true;
        format.type = "nixfmt";
      };

      rust = {
        enable = true;
        lsp.enable = true;
        crates.enable = true;
        format.enable = true;
      };

      lua.enable = true;
      ts.enable = true;
      sql.enable = true;
    };

    lsp = {
      formatOnSave = true;
      lightbulb.enable = true;
      mappings = {
        goToDefinition = "gd";
        codeAction = "<M-cr>";
      };
    };
  };
}
