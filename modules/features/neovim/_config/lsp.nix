{ lib, pkgs, ... }:
{
  plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gD = {
            action = "references";
            desc = "Goto References";
          };
          K = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>r" = {
            action = "rename";
            desc = "Rename";
          };
          "<M-CR>" = {
            action = "code_action";
            desc = "Code Action";
          };
        };
      };
      onAttach = ''
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      '';
      servers = {
        nixd = {
          enable = true;
          settings.formatting.command = [ (lib.getExe pkgs.nixfmt) ];
        };

        eslint = {
          enable = true;
          settings = {
            workingDirectory.mode = "auto";
            nodePath = "node_modules";
          };
        };

        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };

        kotlin_language_server.enable = true;

        tinymist = {
          enable = true;
          settings.formatterMode = "typstyle";
        };
      };
    };

    lsp-format.enable = true;
  };
}
