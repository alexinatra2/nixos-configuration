{ self, inputs, ... }:
{
  flake.modules.homeManager.pdf =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux (
        with pkgs;
        [
          pdfarranger
          qpdf
          poppler-utils
        ]
      );

      programs.sioyek = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        bindings = {
          screen_down = [ "j" "<C-d>" ];
          screen_up = [ "k" "<C-u>" ];
          next_page = [ "<C-f>" ];
          previous_page = [ "<C-b>" ];
          move_left = [ "h" ];
          move_right = [ "l" ];
          next_chapter = [ "]]" ];
          prev_chapter = [ "[[" ];
          search = [ "/" ];
          next_item = [ "n" ];
          previous_item = [ "N" ];
        };
        config = {
          use_legacy_keybinds = "0";
          should_launch_new_window = "0";
          super_fast_search = "1";
          create_table_of_contents_if_not_exists = "1";
          show_document_name_in_statusbar = "1";
          check_for_updates_on_startup = "0";
        };
      };

      xdg = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "application/pdf" = [ "sioyek.desktop" ];
            "application/x-pdf" = [ "sioyek.desktop" ];
          };
        };
      };
    };
}
