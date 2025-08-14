{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs.gnomeExtensions; [
    alttab-mod
  ];

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = with lib.gvariant; {
          "org/gnome/desktop/calendar".show-weekdate = true;
          "org/gnome/desktop/input-sources".sources = [
            (mkTuple [
              "xkb"
              "uk"
            ])
            (mkTuple [
              "xkb"
              "de"
            ])
          ];
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
          "org/gnome/desktop/interface".show-battery-percentage = true;
          "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
          "org/gnome/desktop/privacy".remember-recent-files = false;
          "org/gnome/desktop/screensaver".lock-enabled = false;
          "org/gnome/desktop/session".idle-delay = mkUint32 0;
          "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
          "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
          "org/gnome/mutter" = {
            edge-tiling = true;
            attach-modal-dialogs = true;
            experimental-features = [ "scale-monitor-framebuffer" ];
          };
          "org/gnome/settings-daemon/plugins/power" = {
            # Suspend only on battery power, not while charging.
            sleep-inactive-ac-type = "nothing";
            power-button-action = "interactive";
          };

          "org/gnome/nautilus/preferences".default-folder-viewer = "list-view";
          "org/gnome/nautilus/list-view" = {
            use-tree-view = true;
            default-zoom-level = "small";
          };

          "org/gtk/gtk4/settings/file-chooser" = {
            sort-directories-first = true;
            show-hidden = true;
            view-type = "list";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>Return";
            command = "/usr/bin/env kitty";
            name = "Terminal";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            binding = "<Super>f";
            command = "/usr/bin/env firefox";
            name = "Firefox";
          };

          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];

          "org/gnome/desktop/wm/keybindings" = {
            switch-windows = [ "<Alt>Tab" ];
            switch-applications = [ "<Super>Tab" ];
          };

          "org/gnome/shell".enabled-extensions = [
            "alttab-mod@leleat-on-github"
          ];
        };
      }
    ];
  };
}
