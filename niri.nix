{
  pkgs,
  ...
}:
{
  programs.niri = {
    enable = true;
    settings = {
      binds = {
        "Mod+Return".action.spawn = "kitty";
        "Mod+Shift+F".action.spawn = "firefox";

        "Mod+h" = "focus-column-left";
        "Mod+j".action.focus-window-or-worspace-down = true;
        "Mod+k".action.focus-window-or-worspace-up = true;
        "Mod+l" = "focus-column-right";

        "Mod+Shift+h".action.set-column-width = "-10%";
        "Mod+Shift+l".action.set-column-width = "+10%";

        "Mod+Shift+Q".action.quit.skip-confirmation = true;
      };
    };
  };
}
