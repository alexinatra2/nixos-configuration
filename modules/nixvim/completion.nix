{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      sources.default = [
        "lsp"
        "path"
        "buffer"
      ];
      keymap = {
        "<S-CR>" = [
          "select_and_accept"
        ];
        "<C-space>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<C-e>" = [
          "hide"
        ];
        "<C-n>" = [
          "select_next"
          "fallback"
        ];
        "<C-p>" = [
          "select_prev"
          "fallback"
        ];
        "<S-Tab>" = [
          "snippet_backward"
          "fallback"
        ];
        "<Tab>" = [
          "snippet_forward"
          "fallback"
        ];
        "<Up>" = [
          "select_prev"
          "fallback"
        ];
        "<Down>" = [
          "select_next"
          "fallback"
        ];
      };
    };
  };

  plugins.copilot-lua = {
    enable = true;

    suggestion = {
      enabled = true;
      auto_trigger = true;
    };

    panel.enabled = false;
  };
}
