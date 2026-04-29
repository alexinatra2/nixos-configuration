{ config, ... }:
{
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
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
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
}
