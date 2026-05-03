{ ... }:
{
  plugins.blink-cmp = {
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
}
