{
  self,
  inputs,
  config,
  ...
}:
{
  flake = {
    wrappersModules.niri =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.terminal = lib.mkOption {
          type = lib.types.str;
          default = "kitty";
        };

        config = {
          settings =
            let
              noctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.myNoctalia;
            in
            {
              prefer-no-csd = _: { };

              input = {
                focus-follows-mouse = _: { };

                keyboard = {
                  xkb = {
                    layout = "us,de";
                    options = "grp:alt_shift_toggle,caps:escape";
                  };
                  repeat-rate = 40;
                  repeat-delay = 250;
                };

                touchpad = {
                  natural-scroll = _: { };
                  tap = _: { };
                };

                mouse = {
                  accel-profile = "flat";
                };
              };

              outputs = {
                "PNP(AOC) 24G2W1G4 ATNM61A017051" = {
                  position = _: {
                    props = {
                      x = 0;
                      y = 0;
                    };
                  };
                };

                "LG Electronics 24GM79G 0x0004AB84" = {
                  position = _: {
                    props = {
                      x = 1920;
                      y = 0;
                    };
                  };
                };

                "Samsung Display Corp. 0x4188 Unknown" = {
                  position = _: {
                    props = {
                      x = 0;
                      y = 1080;
                    };
                  };
                };
              };

              binds = {
                "Mod+Shift+Slash".show-hotkey-overlay = _: { };

                "Mod+Return".spawn = config.terminal;

                "Mod+Q".close-window = _: { };
                "Mod+F".maximize-column = _: { };
                "Mod+G".fullscreen-window = _: { };
                "Mod+Shift+F".toggle-window-floating = _: { };
                "Mod+C".center-column = _: { };

                "Mod+H".focus-column-left = _: { };
                "Mod+L".focus-column-right = _: { };
                "Mod+K".focus-window-up = _: { };
                "Mod+J".focus-window-down = _: { };

                "Mod+Left".focus-column-left = _: { };
                "Mod+Right".focus-column-right = _: { };
                "Mod+Up".focus-window-up = _: { };
                "Mod+Down".focus-window-down = _: { };

                "Mod+Ctrl+Left".move-column-to-monitor-left = _: { };
                "Mod+Ctrl+Right".move-column-to-monitor-right = _: { };
                "Mod+Ctrl+Up".move-column-to-monitor-up = _: { };
                "Mod+Ctrl+Down".move-column-to-monitor-down = _: { };

                "Mod+Ctrl+Shift+Left".move-workspace-to-monitor-left = _: { };
                "Mod+Ctrl+Shift+Right".move-workspace-to-monitor-right = _: { };
                "Mod+Ctrl+Shift+Up".move-workspace-to-monitor-up = _: { };
                "Mod+Ctrl+Shift+Down".move-workspace-to-monitor-down = _: { };

                "Mod+Shift+H".move-column-left = _: { };
                "Mod+Shift+L".move-column-right = _: { };
                "Mod+Shift+K".move-window-up = _: { };
                "Mod+Shift+J".move-window-down = _: { };

                "Mod+9".focus-workspace = "w0";
                "Mod+0".focus-workspace = "w1";
                "Mod+Minus".focus-workspace = "w2";
                "Mod+Equal".focus-workspace = "w3";

                "Mod+Shift+9".move-column-to-workspace = "w0";
                "Mod+Shift+0".move-column-to-workspace = "w1";
                "Mod+Shift+Minus".move-column-to-workspace = "w2";
                "Mod+Shift+Equal".move-column-to-workspace = "w3";

                "Mod+Space".spawn-sh = "${noctaliaExe} ipc call launcher toggle";
                "Mod+B".spawn = "firefox";
                "Mod+Comma".spawn-sh = "${noctaliaExe} ipc call settings open";
                "Mod+M".spawn-sh = "${config.pkgs.alsa-utils}/bin/amixer sset Capture toggle";
                "Mod+O".toggle-overview = _: { };
                "Mod+Escape".toggle-keyboard-shortcuts-inhibit = _: { };

                "Print".screenshot = _: { };
                "Ctrl+Print".screenshot-screen = _: { };
                "Alt+Print".screenshot-window = _: { };

                "Mod+Shift+E".quit = _: { };
                "Mod+Shift+P".power-off-monitors = _: { };

                "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
                "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
                "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

                "Mod+Ctrl+H".set-column-width = "50%";
                "Mod+Ctrl+L".set-column-width = "100%";
                "Mod+Ctrl+J".set-window-height = "50%";
                "Mod+Ctrl+K".set-window-height = "100%";

                "Mod+WheelScrollDown".focus-column-left = _: { };
                "Mod+WheelScrollUp".focus-column-right = _: { };
                "Mod+Ctrl+WheelScrollDown".focus-workspace-down = _: { };
                "Mod+Ctrl+WheelScrollUp".focus-workspace-up = _: { };

                "Mod+Ctrl+Minus".set-column-width = "-10%";
                "Mod+Ctrl+Equal".set-column-width = "+10%";

                "Mod+Shift+S".spawn-sh = lib.getExe (
                  config.pkgs.writeShellApplication {
                    name = "screenshot";
                    text = ''
                      ${lib.getExe config.pkgs.grim} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" - \
                      | ${config.pkgs.wl-clipboard}/bin/wl-copy
                    '';
                  }
                );
              };

              layout = {
                gaps = 12;

                focus-ring = {
                  width = 2;
                  active-color = if self ? themeNoHash then "#${self.themeNoHash.base09}" else "#ffb86c";
                };
              };

              workspaces =
                let
                  settings = {
                    layout.gaps = 12;
                  };
                in
                {
                  "w0" = settings;
                  "w1" = settings;
                  "w2" = settings;
                  "w3" = settings;
                };

              window-rules = [
                {
                  geometry-corner-radius = 12;
                  clip-to-geometry = true;
                }
              ];

              xwayland-satellite.path = lib.getExe config.pkgs.xwayland-satellite;

              spawn-at-startup = [
                noctaliaExe
              ]
              ++ lib.optionals (self ? wallpaper) [
                (lib.getExe (
                  pkgs.writeShellScriptBin "wallpaper" "${lib.getExe pkgs.swaybg} -i ${self.wallpaper} -m fill"
                ))
              ];
            };
        };
      };

    nixosModules.niri =
      { pkgs, ... }:
      let
        self' = self.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        programs.niri = {
          enable = true;
          package = self'.niri;
        };

        services.displayManager.sessionPackages = [ self'.niri ];

        environment.systemPackages = with pkgs; [
          xwayland-satellite
        ];

      };

    nixosModules.greeter =
      {
        pkgs,
        lib,
        ...
      }:
      {
        services.displayManager.sddm.enable = false;

        services.greetd = {
          enable = true;
          useTextGreeter = true;
          settings = {
            default_session = {
              user = "greeter";
              command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --cmd niri-session";
            };
          };
        };

        services.displayManager.defaultSession = "niri";

        specialisation = {
          sddm.configuration = {
            services.greetd.enable = lib.mkForce false;
            services.displayManager.sddm = {
              enable = lib.mkForce true;
              wayland.enable = true;
            };
          };

          ly.configuration = {
            services.greetd.enable = lib.mkForce false;
            services.displayManager.ly.enable = true;
            services.displayManager.ly.settings = {
              animation = "matrix";
              bigclock = true;
              clear_password = true;
              default_input = "session";
              hide_borders = true;
              shutdown_key = "F1";
              restart_key = "F2";
            };
          };
        };
      };
  };

  perSystem =
    {
      system,
      pkgs,
      lib,
      ...
    }:
    lib.optionalAttrs (lib.hasSuffix "-linux" system) {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        imports = [ self.wrappersModules.niri ];
      };
    };
}
