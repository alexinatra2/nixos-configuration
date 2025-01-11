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
        format.enable = true;
        crates.enable = true;
      };

      ts = {
        enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      lua.enable = true;
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
