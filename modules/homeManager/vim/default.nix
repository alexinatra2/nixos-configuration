# Vim configuration module - aggregates all vim-related configurations
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim =
    { pkgs, lib, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        extraPackages = [ pkgs.lsof ];

        viAlias = true;
        vimAlias = true;

        globals.mapleader = " ";

        opts = {
          number = true;
          relativenumber = true;
          termguicolors = true;
          completeopt = [
            "menuone"
            "noselect"
            "noinsert"
          ];
          signcolumn = "yes";
          mouse = "a";
          ignorecase = true;
          smartcase = true;
          breakindent = true;
          cursorline = true;
          tabstop = 2;
          shiftwidth = 2;
          clipboard = "unnamedplus";
          encoding = "utf-8";
          fileencoding = "utf-8";
          undofile = true;
          swapfile = true;
          backup = false;
          autoread = true;
        };

        keymaps = [
          {
            action = "<CMD>update<CR>";
            key = "<C-s>";
            options.silent = true;
          }
          {
            mode = [ "i" ];
            action = "<C-w>";
            key = "<M-BS>";
            options.silent = true;
          }
          {
            mode = "n";
            key = "<M-h>";
            action = "<C-w>h";
            options = {
              silent = true;
              desc = "Move to left window";
            };
          }
          {
            mode = "n";
            key = "<M-j>";
            action = "<C-w>j";
            options = {
              silent = true;
              desc = "Move to lower window";
            };
          }
          {
            mode = "n";
            key = "<M-k>";
            action = "<C-w>k";
            options = {
              silent = true;
              desc = "Move to upper window";
            };
          }
          {
            mode = "n";
            key = "<M-l>";
            action = "<C-w>l";
            options = {
              silent = true;
              desc = "Move to right window";
            };
          }
          {
            key = "<M-a>";
            action = "<CMD>lua require('opencode').toggle()<CR>";
            options = {
              desc = "Toggle OpenCode side panel";
              silent = true;
            };
          }
        ];

        plugins.blink-cmp = {
          enable = true;
          settings = {
            sources.default = [
              "lsp"
              "path"
              "buffer"
            ];
            keymap = {
              "<CR>" = [
                "select_and_accept"
                "fallback"
              ];
              "<C-space>" = [
                "show"
                "show_documentation"
                "hide_documentation"
              ];
              "<C-e>" = [ "hide" ];
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

        plugins.lsp = {
          enable = true;
          servers = {
            nixd = {
              enable = true;
              config.formatting.command = [ "${lib.getExe pkgs.nixfmt}" ];
            };
            ts_ls = {
              enable = true;
              config = {
                cmd = [
                  "${pkgs.nodePackages_latest.typescript-language-server}/bin/typescript-language-server"
                  "--stdio"
                ];
                typescript.inlayHints = {
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayVariableTypeHints = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayEnumMemberValueHints = true;
                };
                javascript.inlayHints = {
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
            eslint = {
              enable = true;
              packageFallback = true;
              config.settings = {
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
            pyright.enable = true;
            ruff.enable = true;
            texlab.enable = true;
          };
        };

        plugins.lspsaga = {
          enable = true;
          settings = {
            symbol_in_winbar.enable = false;
            lightbulb.enable = false;
            beacon.enable = false;
            implement.enable = false;
          };
        };

        plugins.telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader><leader>" = "live_grep";
            "<leader>fd" = "diagnostics";
            "<leader>fb" = "lsp_document_symbols";
          };
        };
        plugins.web-devicons.enable = true;

        plugins.treesitter = {
          enable = true;
          settings.highlight.enable = true;
          settings.indent.enable = true;
        };

        plugins.gitsigns.enable = true;

        plugins.oil.enable = true;

        plugins.snacks.enable = true;

        plugins.opencode = {
          enable = true;
          settings = {
            input.enabled = true;
            auto_reload = true;
          };
        };

      };
    };
}
