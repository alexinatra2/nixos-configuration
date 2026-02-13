{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    # For development
    "super+Shift+q".action = quit;

    # Window focus (Mod + arrows)
    "mod+Left".action = focus-window-down-or-column-left;
    "mod+Right".action = focus-window-up-or-column-right;
    "mod+Up".action = focus-window-or-monitor-up;
    "mod+Down".action = focus-window-or-monitor-down;

    # Window focus (Vim keys)
    "mod+h".action = focus-window-down-or-column-left;
    "mod+l".action = focus-window-up-or-column-right;
    "mod+k".action = focus-window-or-monitor-up;
    "mod+j".action = focus-window-or-monitor-down;

    # Move windows (Mod + Shift + arrows)
    "mod+Shift+Left".action = move-window-to-monitor-left;
    "mod+Shift+Right".action = move-window-to-monitor-right;
    "mod+Shift+Up".action = move-window-to-workspace-up;
    "mod+Shift+Down".action = move-window-to-workspace-down;

    # Move windows (Vim keys)
    "mod+Shift+h".action = move-window-to-monitor-left;
    "mod+Shift+l".action = move-window-to-monitor-right;
    "mod+Shift+k".action = move-window-to-workspace-up;
    "mod+Shift+j".action = move-window-to-workspace-down;

    # Workspace switching (Mod + numbers)
    "mod+1".action = focus-workspace "main";
    "mod+2".action = focus-workspace "dev";
    "mod+3".action = focus-workspace "web";
    "mod+4".action = focus-workspace "chat";

    # Workspace switching (Mod + numbers)
    "super+1".action = focus-workspace "main";
    "super+2".action = focus-workspace "dev";
    "super+3".action = focus-workspace "web";

    # Launch applications
    "mod+Return".action = spawn "${lib.getExe pkgs.kitty}";
    "mod+Space".action = spawn "${lib.getExe pkgs.rofi} -show drun";
  };
}
