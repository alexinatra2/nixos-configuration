# tui.json configuration for opencode, mirroring https://opencode.ai/tui.json.
{ lib, pkgs }:

let
  jsonType = (pkgs.formats.json { }).type;

  keyNameType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Key name, e.g. `n`, `F5`.";
      };

      ctrl = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require Ctrl.";
      };

      shift = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require Shift.";
      };

      meta = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require Meta.";
      };

      super = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require Super.";
      };

      hyper = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require Hyper.";
      };
    };
  };

  chordType = lib.types.submodule {
    options = {
      key = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          keyNameType
        ];
        description = "Key of the chord.";
      };

      event = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "press"
            "release"
          ]
        );
        default = null;
        description = "Whether the chord fires on key press or release.";
      };

      preventDefault = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Prevent the default behavior of the key.";
      };

      fallthrough = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Pass the key through to the underlying app.";
      };
    };
  };

  keybindValueType = lib.types.nullOr (
    lib.types.oneOf [
      (lib.types.enum [
        false
        "none"
      ])
      lib.types.str
      keyNameType
      chordType
      (lib.types.listOf (
        lib.types.oneOf [
          lib.types.str
          keyNameType
          chordType
        ]
      ))
    ]
  );

  keybindEvents = [
    "leader"
    "app_exit"
    "app_debug"
    "app_console"
    "app_heap_snapshot"
    "app_toggle_animations"
    "app_toggle_file_context"
    "app_toggle_diffwrap"
    "app_toggle_paste_summary"
    "app_toggle_session_directory_filter"
    "command_list"
    "help_show"
    "docs_open"
    "diff_open"
    "diff_close"
    "diff_toggle"
    "diff_expand"
    "diff_expand_all"
    "diff_collapse"
    "diff_switch_focus"
    "diff_next_hunk"
    "diff_previous_hunk"
    "diff_next_file"
    "diff_previous_file"
    "diff_toggle_file_tree"
    "diff_single_patch"
    "diff_switch_source"
    "diff_toggle_view"
    "diff_help"
    "editor_open"
    "theme_list"
    "theme_switch_mode"
    "theme_mode_lock"
    "sidebar_toggle"
    "scrollbar_toggle"
    "status_view"
    "debug_view"
    "session_export"
    "session_copy"
    "session_move"
    "session_new"
    "session_list"
    "session_timeline"
    "session_fork"
    "session_rename"
    "session_delete"
    "session_share"
    "session_unshare"
    "session_interrupt"
    "session_background"
    "session_compact"
    "session_toggle_timestamps"
    "session_toggle_generic_tool_output"
    "session_queued_prompts"
    "session_child_first"
    "session_child_cycle"
    "session_child_cycle_reverse"
    "session_parent"
    "session_pin_toggle"
    "session_quick_switch_1"
    "session_quick_switch_2"
    "session_quick_switch_3"
    "session_quick_switch_4"
    "session_quick_switch_5"
    "session_quick_switch_6"
    "session_quick_switch_7"
    "session_quick_switch_8"
    "session_quick_switch_9"
    "stash_delete"
    "model_provider_list"
    "model_favorite_toggle"
    "model_list"
    "model_cycle_recent"
    "model_cycle_recent_reverse"
    "model_cycle_favorite"
    "model_cycle_favorite_reverse"
    "mcp_list"
    "provider_connect"
    "console_org_switch"
    "agent_list"
    "agent_cycle"
    "agent_cycle_reverse"
    "variant_cycle"
    "variant_list"
    "messages_page_up"
    "messages_page_down"
    "messages_line_up"
    "messages_line_down"
    "messages_half_page_up"
    "messages_half_page_down"
    "messages_first"
    "messages_last"
    "messages_next"
    "messages_previous"
    "messages_last_user"
    "messages_copy"
    "messages_undo"
    "messages_redo"
    "messages_toggle_conceal"
    "tool_details"
    "display_thinking"
    "prompt_submit"
    "prompt_editor_context_clear"
    "prompt_skills"
    "prompt_stash"
    "prompt_stash_pop"
    "prompt_stash_list"
    "workspace_set"
    "input_clear"
    "input_paste"
    "input_submit"
    "input_newline"
    "input_move_left"
    "input_move_right"
    "input_move_up"
    "input_move_down"
    "input_select_left"
    "input_select_right"
    "input_select_up"
    "input_select_down"
    "input_line_home"
    "input_line_end"
    "input_select_line_home"
    "input_select_line_end"
    "input_visual_line_home"
    "input_visual_line_end"
    "input_select_visual_line_home"
    "input_select_visual_line_end"
    "input_buffer_home"
    "input_buffer_end"
    "input_select_buffer_home"
    "input_select_buffer_end"
    "input_delete_line"
    "input_delete_to_line_end"
    "input_delete_to_line_start"
    "input_backspace"
    "input_delete"
    "input_undo"
    "input_redo"
    "input_word_forward"
    "input_word_backward"
    "input_select_word_forward"
    "input_select_word_backward"
    "input_delete_word_forward"
    "input_delete_word_backward"
    "input_select_all"
    "history_previous"
    "history_next"
    "dialog.select.prev"
    "dialog.select.next"
    "dialog.select.page_up"
    "dialog.select.page_down"
    "dialog.select.home"
    "dialog.select.end"
    "dialog.select.submit"
    "dialog.prompt.submit"
    "dialog.mcp.toggle"
    "dialog.move_session.new"
    "dialog.move_session.delete"
    "dialog.move_session.refresh"
    "prompt.autocomplete.prev"
    "prompt.autocomplete.next"
    "prompt.autocomplete.hide"
    "prompt.autocomplete.select"
    "prompt.autocomplete.complete"
    "permission.prompt.fullscreen"
    "plugins.toggle"
    "dialog.plugins.install"
    "terminal_suspend"
    "terminal_title_toggle"
    "tips_toggle"
    "plugin_manager"
    "plugin_install"
    "which_key_toggle"
    "which_key_layout_toggle"
    "which_key_pending_toggle"
    "which_key_group_previous"
    "which_key_group_next"
    "which_key_scroll_up"
    "which_key_scroll_down"
    "which_key_page_up"
    "which_key_page_down"
    "which_key_home"
    "which_key_end"
  ];

  keybindsType = lib.types.attrsOf keybindValueType;

  tuiType = lib.types.submodule {
    options = {
      "$schema" = lib.mkOption {
        type = lib.types.str;
        default = "https://opencode.ai/tui.json";
        internal = true;
        description = "Schema reference for tui.json.";
      };

      theme = lib.mkOption {
        type = lib.types.str;
        default = "stylix";
        description = "Color theme of the TUI.";
      };

      keybinds = lib.mkOption {
        type = lib.types.nullOr keybindsType;
        default = null;
        description = "Keybindings keyed by event name (see tui.json schema).";
      };

      plugin = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "TUI plugins to load.";
      };

      plugin_enabled = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "TUI plugins to enable. (opencode.json: `plugin_enabled`)";
      };

      leader_timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Timeout in ms for the leader key chord.";
      };

      attention = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              maxHeight = lib.mkOption {
                type = lib.types.ints.positive;
                description = "Maximum height in lines.";
              };

              maxWidth = lib.mkOption {
                type = lib.types.ints.positive;
                description = "Maximum width in columns.";
              };

              mode = lib.mkOption {
                type = lib.types.enum [
                  "auto"
                  "fixed"
                  "disabled"
                ];
                default = "auto";
                description = "Attention window sizing mode.";
              };
            };
          }
        );
        default = null;
        description = "Attention window configuration.";
      };

      prompt = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.oneOf [
            (lib.types.enum [ "auto" ])
            (lib.types.submodule {
              options = {
                maxHeight = lib.mkOption {
                  type = lib.types.nullOr lib.types.ints.positive;
                  default = null;
                  description = "Maximum prompt height.";
                };

                maxWidth = lib.mkOption {
                  type = lib.types.nullOr lib.types.ints.positive;
                  default = null;
                  description = "Maximum prompt width.";
                };
              };
            })
          ]
        );
        default = null;
        description = "Prompt sizing.";
      };

      scroll_speed = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Scroll speed in lines per scroll.";
      };

      scroll_acceleration = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Scroll speed acceleration factor.";
      };

      diff_style = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "auto"
            "stacked"
          ]
        );
        default = null;
        description = "Diff rendering style.";
      };

      mouse = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              enabled = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable mouse support.";
              };

              maxWheelRows = lib.mkOption {
                type = lib.types.ints.positive;
                default = 3;
                description = "Maximum rows per wheel tick.";
              };

              maxWheelCols = lib.mkOption {
                type = lib.types.ints.positive;
                default = 10;
                description = "Maximum columns per wheel tick.";
              };
            };
          }
        );
        default = null;
        description = "Mouse configuration.";
      };
    };
  };

  render = import ./render.nix { inherit lib; };

  renderTui = tui: builtins.toJSON (render.clean tui);
in
{
  inherit
    tuiType
    keybindEvents
    keyNameType
    chordType
    ;
  inherit renderTui jsonType;
}
