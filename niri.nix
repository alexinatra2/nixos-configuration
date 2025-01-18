{
  pkgs,
  config,
  ...
}:
{
  programs.niri = {
    enable = true;
    settings = {
      binds =
        with config.lib.niri.actions;
        let
          sh = spawn "sh" "-c";
        in
        {
          "Mod+Return".action = spawn "kitty";
          "Mod+Shift+F".action = spawn "firefox";

          "Mod+h" = "focus-column-left";
          "Mod+l" = "focus-column-right";

          "Mod+Shift+h".action.set-column-width = "-10%";
          "Mod+Shift+l".action.set-column-width = "+10%";

          "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
          "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

          "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
          "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";

          "Mod+Q".action = close-window;

          "Mod+Shift+Q".action.quit.skip-confirmation = true;
        };
    };
  };
}
