{
  pkgs,
  config,
  lib,
  ...
}:
let
  binds =
    {
      suffixes,
      prefixes,
      substitutions ? { },
    }:
    with lib;
    let
      replacer = replaceStrings (attrNames substitutions) (attrValues substitutions);
      format =
        prefix: suffix:
        let
          actual-suffix =
            if isList suffix.action then
              {
                action = head suffix.action;
                args = tail suffix.action;
              }
            else
              {
                inherit (suffix) action;
                args = [ ];
              };

          action = replacer "${prefix.action}-${actual-suffix.action}";
        in
        {
          name = "${prefix.key}+${suffix.key}";
          value.action.${action} = actual-suffix.args;
        };
      pairs =
        attrs: fn:
        concatMap (
          key:
          fn {
            inherit key;
            action = attrs.${key};
          }
        ) (attrNames attrs);
    in
    listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [ (format prefix suffix) ])));
in
{
  home.packages = with pkgs; [
    wl-clipboard
    wayland-utils
  ];

  programs.niri = {
    enable = true;
    settings = {
      input = {
        mouse.accel-speed = 1.0;
        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
          click-method = "clickfinger";
        };
        tablet.map-to-output = "eDP-1";
        touch.map-to-output = "eDP-1";
      };

      layout = {
        gaps = 16;
        struts.left = 64;
        struts.right = 64;
        border.width = 4;
        always-center-single-column = true;

        empty-workspace-above-first = true;
      };

      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

      switch-events =
        with config.lib.niri.actions;
        let
          sh = spawn "sh" "-c";
        in
        {
          tablet-mode-on.action = sh "notify-send tablet-mode-on";
          tablet-mode-off.action = sh "notify-send tablet-mode-off";
          lid-open.action = sh "notify-send lid-open";
          lid-close.action = sh "notify-send lid-close";
        };

      binds =
        with config.lib.niri.actions;
        let
          sh = spawn "sh" "-c";
          # this is just because I copied this from https://github.com/sodiboo/system/blob/main/niri.mod.nix
          Mod = "Mod";
        in
        lib.attrsets.mergeAttrsList [
          {
            "${Mod}+Return".action = spawn "kitty";
            "${Mod}+W".action = sh (
              builtins.concatStringsSep "; " [
                "systemctl --user restart waybar.service"
                "systemctl --user restart swaybg.service"
              ]
            );

            "${Mod}+L".action = spawn "blurred-locker";

            "${Mod}+Shift+S".action = screenshot;
            "Print".action = screenshot-screen;
            "${Mod}+Print".action = screenshot-window;

            "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
            "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

            "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
            "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";

            "${Mod}+Q".action = close-window;

            "${Mod}+Tab".action = focus-window-down-or-column-right;
            "${Mod}+Shift+Tab".action = focus-window-up-or-column-left;
          }
          (binds {
            suffixes."H" = "column-left";
            suffixes."J" = "window-down";
            suffixes."K" = "window-up";
            suffixes."L" = "column-right";
            prefixes."${Mod}" = "focus";
            prefixes."${Mod}+Ctrl" = "move";
            prefixes."${Mod}+Shift" = "focus-monitor";
            prefixes."${Mod}+Shift+Ctrl" = "move-window-to-monitor";
            substitutions."monitor-column" = "monitor";
            substitutions."monitor-window" = "monitor";
          })
          {
            "${Mod}+V".action = switch-focus-between-floating-and-tiling;
            "${Mod}+Shift+V".action = toggle-window-floating;
          }
          (binds {
            suffixes."Home" = "first";
            suffixes."End" = "last";
            prefixes."${Mod}" = "focus-column";
            prefixes."${Mod}+Ctrl" = "move-column-to";
          })
          (binds {
            suffixes."U" = "workspace-down";
            suffixes."I" = "workspace-up";
            prefixes."${Mod}" = "focus";
            prefixes."${Mod}+Ctrl" = "move-window-to";
            prefixes."${Mod}+Shift" = "move";
          })
          (binds {
            suffixes = builtins.listToAttrs (
              map (n: {
                name = toString n;
                value = [
                  "workspace"
                  (n + 1)
                ]; # workspace 1 is empty; workspace 2 is the logical first.
              }) (lib.range 1 9)
            );
            prefixes."${Mod}" = "focus";
            prefixes."${Mod}+Ctrl" = "move-window-to";
          })
          {
            "${Mod}+Comma".action = consume-window-into-column;
            "${Mod}+Period".action = expel-window-from-column;

            "${Mod}+R".action = switch-preset-column-width;
            "${Mod}+M".action = maximize-column;
            "${Mod}+Shift+M".action = fullscreen-window;
            "${Mod}+C".action = center-column;

            "${Mod}+Minus".action = set-column-width "-10%";
            "${Mod}+Plus".action = set-column-width "+10%";
            "${Mod}+Shift+Minus".action = set-window-height "-10%";
            "${Mod}+Shift+Plus".action = set-window-height "+10%";

            "${Mod}+Shift+E".action = quit;
            "${Mod}+Shift+P".action = power-off-monitors;

            "${Mod}+Shift+Ctrl+T".action = toggle-debug-tint;
          }
        ];

      window-rules =
        let
          colors = config.lib.stylix.colors.withHashtag;
        in
        [
          {
            geometry-corner-radius =
              let
                r = 8.0;
              in
              {
                top-left = r;
                top-right = r;
                bottom-left = r;
                bottom-right = r;
              };
            clip-to-geometry = true;
          }
          {
            matches = [ { is-focused = false; } ];
            opacity = 0.95;
          }
          {
            matches = [
              {
                app-id = "^kitty$";
                title = ''^\[oxygen\]'';
              }
            ];
            border.active.color = colors.base0B;
          }
          {
            matches = [
              {
                app-id = "^firefox$";
                title = "Private Browsing";
              }
            ];
            border.active.color = colors.base0E;
          }
        ];

      spawn-at-startup =
        let
          get-wayland-display = "systemctl --user show-environment | awk -F 'WAYLAND_DISPLAY=' '{print $2}' | awk NF";
          wrapper =
            name: op:
            pkgs.writeScript "${name}" ''
              if [ "$(${get-wayland-display})" ${op} "$WAYLAND_DISPLAY" ]; then
                exec "$@"
              fi
            '';

          only-on-session = wrapper "only-on-session" "=";
          only-without-session = wrapper "only-without-session" "!=";
        in
        [
          {
            command = [
              "${only-without-session}"
              "${lib.getExe pkgs.waybar}"
            ];
          }
          {
            command = [
              "${only-without-session}"
              "${lib.getExe pkgs.swaybg}"
              "-m"
              "fill"
              "-i"
              "background.png"
            ];
          }
          {
            command =
              let
                units = [
                  "niri"
                  "graphical-session.target"
                  "xdg-desktop-portal"
                  "xdg-desktop-portal-gnome"
                  "waybar"
                ];
                commands = builtins.concatStringsSep ";" (map (unit: "systemctl --user status ${unit}") units);
              in
              [
                "${only-on-session}"
                "kitty"
                "--"
                "sh"
                "-c"
                "env SYSTEMD_COLORS=1 watch -n 1 -d --color '${commands}'"
              ];
          }
          {
            command = [
              "${only-without-session}"
              "kitty"
              "--"
              "sh"
              "-c"
              "${lib.getExe pkgs.wayvnc} -L=debug"
            ];
          }
        ];
      outputs =
        let
          cfg = config.programs.niri.settings.outputs;
        in
        {
          "eDP-1" = {
            scale = 2.0;
            mode = {
              width = 2880;
              height = 1800;
              refresh = 120.0;
            };
            # align to the right edge of the monitor on top
            position = {
              x = 0;
              y = 0;
            };
          };
          # TV
          "DP-6" = {
            scale = 2.0;
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            # top left corner
            position = {
              x = -cfg."DP-6".mode.width;
              y = -cfg."DP-7".mode.height;
            };
          };
          # AOC
          "DP-7" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 144.0;
            };
            # top center
            position = {
              x = 0;
              y = -cfg."DP-7".mode.height;
            };
          };
          # LG
          "DP-8" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 120.0;
            };
            # top right
            position = {
              x = cfg."DP-8".mode.width;
              y = -cfg."DP-7".mode.height;
            };
          };
        };
    };
  };
}
