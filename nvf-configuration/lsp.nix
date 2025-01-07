{
  ...
}:
{
  programs.nvf.settings.vim = {
    languages = {
      enableLSP = true;
      enableTreesitter = true;
      enableFormat = true;

      # enabled languages
      nix = {
        enable = true;
        format.type = "nixfmt";
      };

      rust.enable = true;
      html.enable = true;
      lua.enable = true;
      ts.enable = true;
      python.enable = true;
      java.enable = true;
      kotlin.enable = true;
      sql.enable = true;
      tailwind.enable = true;
      bash.enable = true;
      clang.enable = true;
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
