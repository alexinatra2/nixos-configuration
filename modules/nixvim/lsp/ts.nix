{
  lib,
  pkgs,
  ...
}:
{
  lsp.servers = {
    ts_ls = {
      enable = true;

      config = {
        cmd = [
          "${pkgs.nodePackages_latest.typescript-language-server}/bin/typescript-language-server"
          "--stdio"
        ];

        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all";
            includeInlayParameterNameHintsWhenArgumentMatchesName = false;
            includeInlayFunctionParameterTypeHints = true;
            includeInlayVariableTypeHints = true;
            includeInlayPropertyDeclarationTypeHints = true;
            includeInlayFunctionLikeReturnTypeHints = true;
            includeInlayEnumMemberValueHints = true;
          };
        };

        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all";
            includeInlayParameterNameHintsWhenArgumentMatchesName = false;
            includeInlayFunctionParameterTypeHints = true;
            includeInlayVariableTypeHints = true;
            includeInlayPropertyDeclarationTypeHints = true;
            includeInlayFunctionLikeReturnTypeHints = true;
            includeInlayEnumMemberValueHints = true;
          };
        };

        on_attach = lib.nixvim.mkRaw ''
          function(client, bufnr)
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        '';
      };
    };

    eslint = {
      enable = true;
      packageFallback = true;
      config = {
        settings = {
          workingDirectory = {
            mode = "auto";
          };
          nodePath = "node_modules";
        };
      };
    };
  };
}
