{ self, inputs, ... }:
{
  flake.modules.homeManager.neovim =
    { config, lib, pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [ lsof ];

        globals = {
          mapleader = " ";
          netrw_winsize = 20;
          netrw_liststyle = 3;
        };

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
            mode = "x";
            action = "\"_dP";
            key = "<leader>p";
            options.silent = true;
          }
          {
            mode = [
              "n"
              "v"
            ];
            action = "\"_d";
            key = "<leader>d";
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
            key = "<M-n>";
            action = "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<CR>";
            options = {
              desc = "Next Diagnostic";
              silent = true;
            };
          }
          {
            key = "<M-N>";
            action = "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<CR>";
            options = {
              desc = "Previous Diagnostic";
              silent = true;
            };
          }
          {
            key = "<leader>fw";
            action.__raw = ''
              function()
                local word = vim.fn.expand("<cword>")
                require("telescope.builtin").grep_string({ search = word })
              end
            '';
            options = {
              silent = true;
              desc = "Find word under cursor";
            };
          }
          {
            key = "<leader>fW";
            action.__raw = ''
              function()
                local word = vim.fn.expand("<cWord>")
                require("telescope.builtin").grep_string({ search = word })
              end
            '';
            options = {
              silent = true;
              desc = "Find Word under cursor";
            };
          }
          {
            action = "<CMD>LazyGit<CR>";
            key = "<leader>gg";
            options = {
              silent = true;
              desc = "LazyGit";
            };
          }
          {
            action = "<CMD>Gitsigns next_hunk<CR>";
            key = "]h";
            options = {
              silent = true;
              desc = "Next git hunk [Gitsigns]";
            };
          }
          {
            action = "<CMD>Gitsigns prev_hunk<CR>";
            key = "[h";
            options = {
              silent = true;
              desc = "Previous git hunk [Gitsigns]";
            };
          }
          {
            action = "<CMD>Gitsigns stage_hunk<CR>";
            key = "<leader>gs";
            options = {
              silent = true;
              desc = "Stage git hunk [Gitsigns]";
            };
          }
          {
            action = "<CMD>Gitsigns reset_hunk<CR>";
            key = "<leader>gr";
            options = {
              silent = true;
              desc = "Reset git hunk [Gitsigns]";
            };
          }
          {
            action = "<CMD>Gitsigns reset_buffer<CR>";
            key = "<leader>gR";
            options = {
              silent = true;
              desc = "Reset file [Gitsigns]";
            };
          }
          {
            action = "<CMD>Gitsigns blame<CR>";
            key = "<M-b>";
            options = {
              silent = true;
              desc = "Open blame [Gitsigns]";
            };
          }
          {
            action = "<CMD>Gitsigns toggle_word_diff<CR>";
            key = "<leader>gd";
            options = {
              silent = true;
              desc = "Toggle word diff [Gitsigns]";
            };
          }
          {
            key = "<M-e>";
            action = "<cmd>Oil<cr>";
            options.silent = true;
          }
        ];

        userCommands.MergedLogs = {
          desc = "Open last 500 lines of Neovim logs in vertical terminal";
          command = ''
            :vertical terminal bash -c 'find $HOME/.local/state/nvim -type f -name "*.log" | xargs -I{} tail -n 500 "{}" | sort -r'
          '';
          nargs = 0;
          force = true;
        };

        plugins = {
          blink-cmp = {
            enable = true;
            setupLspCapabilities = true;
            settings = {
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
              completion = {
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 500;
                  treesitter_highlighting = true;
                };
                ghost_text.enabled = true;
                list.cycle = {
                  from_bottom = true;
                  from_top = true;
                };
                menu = {
                  auto_show = true;
                  border = "single";
                  max_height = 10;
                };
                trigger = {
                  show_on_keyword = true;
                  show_on_trigger_character = true;
                };
              };
              signature = {
                enabled = true;
                trigger.enabled = true;
                window.border = "single";
              };
            };
          };

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

              ts_ls = {
                enable = true;
                settings = {
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
                settings = {
                  workingDirectory.mode = "auto";
                  nodePath = "node_modules";
                };
              };

              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
              };
              kotlin_language_server.enable = true;
              ty.enable = true;
              texlab.enable = true;
              tinymist = {
                enable = true;
                settings.formatterMode = "typstyle";
              };
            };
          };

          lsp-format.enable = true;

          telescope = {
            enable = true;
            keymaps = {
              "<leader>ff" = "find_files";
              "<leader>f/" = "live_grep";
              "<leader>fg" = "git_status";
              "<leader>fd" = "diagnostics";
              "<leader>fz" = "current_buffer_fuzzy_find";
              "<leader>fs" = "lsp_document_symbols";
              "<leader>fi" = "builtin";
              "<leader>fh" = "help_tags";
              "<leader>fo" = "oldfiles";
            };
          };

          web-devicons.enable = true;
          treesitter = {
            enable = true;
            highlight.enable = true;
            indent.enable = true;
            grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
              typescript
              tsx
              javascript
              lua
              json
              html
              css
              nix
              rust
            ];
          };
          treesitter-textobjects.enable = true;
          lazygit.enable = true;
          gitsigns = {
            enable = true;
            settings.current_line_blame = true;
          };
          oil.enable = true;
          toggleterm = {
            enable = true;
            settings = {
              direction = "float";
              open_mapping = "[[<M-i>]]";
              shell = "tmux new-session -A -s nvim-term";
            };
          };
          which-key.enable = true;
          yanky.enable = true;
          auto-session.enable = true;
          noice.enable = true;
        };
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
