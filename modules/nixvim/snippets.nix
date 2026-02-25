{
  plugins.luasnip = {
    enable = true;
    settings = {
      enable_autosnippets = true;
      store_selection_keys = "<Tab>";
    };
    fromSnipmate = [
      {
        paths = ./snippets/markdown.snippets;
        include = [ "markdown" ];
      }
      {
        paths = ./snippets/html.snippets;
        include = [ "html" ];
      }
      {
        paths = ./snippets/rust.snippets;
        include = [ "rust" ];
      }
      {
        paths = ./snippets/lua.snippets;
        include = [ "lua" ];
      }
      {
        paths = ./snippets/css.snippets;
        include = [ "css" ];
      }
      {
        paths = ./snippets/typescript.snippets;
        include = [ "typescript" ];
      }
      {
        paths = ./snippets/typescriptreact.snippets;
        include = [ "typescript-react" ];
      }
      {
        paths = ./snippets/bash.snippets;
        include = [ "bash" ];
      }
      {
        paths = ./snippets/zsh.snippets;
        include = [ "zsh" ];
      }
    ];
  };
  plugins.friendly-snippets.enable = true;
}
