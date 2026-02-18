{
  lib,
  pkgs,
  ...
}:
{
  plugins.lsp.servers = {
    # Nix
    nixd = {
      enable = true;
      config = {
        formatting.command = [ "${lib.getExe pkgs.nixfmt}" ];
      };
    };

    # TypeScript/JavaScript
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

    # Rust
    rust_analyzer = {
      enable = true;
      installCargo = true;
      installRustc = true;
    };

    # Kotlin
    kotlin_language_server.enable = true;

    # Python
    pyright.enable = true;
    ruff.enable = true;

    # LaTeX
    texlab.enable = true;
  };
}
