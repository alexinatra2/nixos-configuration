{
  programs.nvf.settings.vim = {
    lsp = {
      enable = true;
      formatOnSave = true;
      lightbulb.enable = true;
      mappings = {
        goToDefinition = "gd";
        codeAction = "<M-cr>";
      };
    };

    languages = {
      # enabled languages
      nix = {
        enable = true;
        format.type = "nixfmt";
      };

      ts = {
        enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      clang.enable = true;
      lua.enable = true;
      sql.enable = true;
    };
  };
}
