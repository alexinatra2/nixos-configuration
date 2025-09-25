{ pkgs, ... }:
{
  programs.nvf.settings.vim.lazy.plugins."conform.nvim" = {
    package = pkgs.vimPlugins.conform-nvim;
    event = [ "BufWritePre" ];
    cmd = [ "ConformInfo" ];
    setupModule = "conform";
    setupOpts = {
      formatters_by_ft = {
        lua = [ "stylua" ];
        python = [
          "isort"
          "black"
        ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        vue = [ "prettier" ];
        css = [ "prettier" ];
        scss = [ "prettier" ];
        less = [ "prettier" ];
        html = [ "prettier" ];
        json = [ "prettier" ];
        jsonc = [ "prettier" ];
        yaml = [ "prettier" ];
        markdown = [ "prettier" ];
        graphql = [ "prettier" ];
        handlebars = [ "prettier" ];
        rust = [ "rustfmt" ];
        nix = [ "nixfmt" ];
        sh = [ "shfmt" ];
        go = [ "gofmt" ];
      };
      format_on_save = {
        timeout_ms = 500;
        lsp_fallback = true;
      };
    };
    keys = [
      {
        key = "<leader>mp";
        mode = [
          "n"
          "v"
        ];
        silent = true;
        lua = true;
        action = "function() require('conform').format({ lsp_fallback = true }) end";
        desc = "Format file or range (in visual mode)";
      }
    ];
  };
}
