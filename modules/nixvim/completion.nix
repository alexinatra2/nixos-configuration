{
  plugins.blink-cmp = {
    enable = true;

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
        appearance = {
          highlight_ns = null;
          kind_icons = null;
          nerd_font_variant = null;
          use_nvim_cmp_as_default = null;
        };
        completion = {
          accept = {
            auto_brackets = {
              blocked_filetypes = null;
              default_brackets = null;
              enabled = true;
              force_allow_filetypes = null;
              kind_resolution = {
                blocked_filetypes = null;
                enabled = true;
              };
              override_brackets_for_filetypes = null;
              semantic_token_resolution = {
                blocked_filetypes = null;
                enabled = true;
                timeout_ms = null;
              };
            };
            create_undo_point = true;
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 500;
            treesitter_highlighting = true;
            update_delay_ms = null;
            window = {
              border = null;
              desired_min_height = null;
              desired_min_width = null;
              direction_priority = {
                menu_north = null;
                menu_south = null;
              };
              max_height = null;
              max_width = null;
              min_width = null;
              scrollbar = null;
              winblend = null;
              winhighlight = null;
            };
          };
          ghost_text.enabled = true;
          keyword = {
            exclude_from_prefix_regex = null;
            range = null;
            regex = null;
          };
          list = {
            cycle = {
              from_bottom = true;
              from_top = true;
            };
            max_items = null;
            selection = null;
          };
          menu = {
            # Automatically show the completion popup as you type.
            auto_show = true;

            # Border style of the completion popup window.
            # One of: "single", "double", "rounded", "solid", "shadow".
            border = "single";

            # Maximum number of visible items before scrolling.
            max_height = 10;

            # --- Optional / Advanced options below ---

            # cmdline_position = null;        # Adjust menu position for command-line mode.
            # direction_priority = null;      # Controls where to open popup if space is limited.
            # draw = null;                    # Custom Lua function to control how items are drawn.
            # enabled = null;                 # Disable completion menu entirely if false.
            # min_width = null;               # Minimum width (columns) for popup window.
            # order = {                       # Fine-grained control over popup stacking order.
            #   n = null;
            #   s = null;
            # };
            # scrollbar = null;               # Whether to show scrollbar; default auto.
            # scrolloff = null;               # Keeps N items visible above/below selection.
            # winblend = null;                # Window transparency (0=opaque, 100=invisible).
            # winhighlight = null;            # Highlight groups (e.g. "Normal:CmpPmenu,FloatBorder:CmpBorder").
          };

          trigger = {
            # Trigger completion automatically when typing words.
            show_on_keyword = true;

            # Trigger completion when typing specific characters like '.', ':', or '>'.
            show_on_trigger_character = true;

            # --- Optional / Advanced options below ---

            # prefetch_on_insert = null;                 # Prefetch items during insert mode for lower latency.
            # show_in_snippet = null;                    # Whether to trigger inside snippet placeholders.
            # show_on_accept_on_trigger_character = null;# Immediately retrigger after accepting completion.
            # show_on_blocked_trigger_characters = null; # Force trigger on normally blocked characters.
            # show_on_insert_on_trigger_character = null;# Trigger after insertion of a trigger character.
            # show_on_x_blocked_trigger_characters = null;# Extended blocked trigger behavior; rarely used.
          };
        };
        fuzzy = {
          # Sort completion results based on recency and frequency of selection.
          # Keeps commonly used items ranked higher over time.
          use_frecency = true;

          # Allow fuzzy matching to tolerate minor typos.
          # Example: "pritn" still matches "print".
          use_typo_resistance = true;

          # --- Optional / Advanced options below ---

          # sorts = null;              # Custom list of sort strategies (e.g. ["frecency" "score"]).
          # Leave null to use plugin defaults.

          # use_proximity = null;      # Rank by proximity to cursor (useful for LSP symbols).
          # Slightly slower; usually not needed globally.

          # use_unsafe_no_lock = null; # Disables internal concurrency locks.
          # Only useful for debugging; may cause race conditions.
        };
        signature = {
          # Enable inline function signature help (shows parameters as you type).
          enabled = true;

          trigger = {
            # Enable signature help when typing trigger characters such as '('.
            enabled = true;

            # --- Optional / Advanced options below ---

            # blocked_retrigger_characters = null;   # Characters that prevent retriggering after popup shown.
            # blocked_trigger_characters = null;     # Characters that should *not* trigger signature help.
            # show_on_insert_on_trigger_character = null; # Show signature help immediately after inserting trigger char.
          };

          window = {
            # Use a simple single border around the signature popup.
            border = "single";

            # --- Optional / Advanced options below ---

            # direction_priority = null;          # Controls preferred direction if window would overflow.
            # max_height = null;                  # Maximum popup height (lines); auto-sized if null.
            # max_width = null;                   # Maximum popup width (columns); auto-sized if null.
            # min_width = null;                   # Minimum width before truncation.
            # scrollbar = null;                   # Show scrollbar if content exceeds window height.
            # treesitter_highlighting = null;     # Enable Treesitter-based syntax highlighting in popup.
            # winblend = null;                    # Transparency (0 = opaque, 100 = fully transparent).
            # winhighlight = null;                # Highlight groups, e.g. "Normal:CmpPmenu,FloatBorder:CmpBorder".
          };
        };
        snippets = {
          active = null;
          expand = null;
          jump = null;
        };
        sources = {
          cmdline = null;
          default = [
            "lsp"
            "path"
            "buffer"
          ];
          min_keyword_length = null;
          per_filetype = null;
          providers = null;
          transform_items = null;
        };
      };
    };
  };
}
