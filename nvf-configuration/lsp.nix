{
  programs.nvf.settings.vim = {
    lsp = {
      enable = true;
      formatOnSave = true;
      lightbulb.enable = true;
      lspSignature.enable = true;
      trouble.enable = true;
      mappings = {
        goToDefinition = "gd";
        goToDeclaration = "gD";
        goToType = "<leader>gt";
        listImplementations = "gi";
        listReferences = "gr";
        nextDiagnostic = "]d";
        previousDiagnostic = "[d";
        openDiagnosticFloat = "<leader>e";
        codeAction = "<leader>ca";
        rename = "<leader>rn";
        documentHighlight = "<leader>h";
      };
    };

    languages = {
      # enabled languages
      nix = {
        enable = true;
        format.type = "nixfmt";
        lsp.enable = true;
      };

      ts = {
        enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
        lsp.enable = true;
      };

      clang = {
        enable = true;
        lsp.enable = true;
      };

      lua = {
        enable = true;
        lsp.enable = true;
      };

      sql = {
        enable = true;
        lsp.enable = true;
      };

      rust = {
        enable = true;
        crates.enable = true;
        lsp.enable = true;
        dap.enable = true;
      };

      python = {
        enable = true;
        lsp.enable = true;
        dap.enable = true;
        format.enable = true;
      };

      java = {
        enable = true;
        lsp.enable = true;
      };

      go = {
        enable = true;
        lsp.enable = true;
        dap.enable = true;
      };

      html = {
        enable = true;
        lsp.enable = true;
      };

      css = {
        enable = true;
        lsp.enable = true;
      };

      markdown = {
        enable = true;
        lsp.enable = true;
      };

      dart = {
        enable = true;
        lsp.enable = true;
      };

      bash = {
        enable = true;
        lsp.enable = true;
      };

      tailwind.enable = true;
    };
  };
}
