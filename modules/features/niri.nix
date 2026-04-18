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
                    layout = "us,ru,ua";
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

              binds = {
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

                "Mod+Shift+H".move-column-left = _: { };
                "Mod+Shift+L".move-column-right = _: { };
                "Mod+Shift+K".move-window-up = _: { };
                "Mod+Shift+J".move-window-down = _: { };

                "Mod+1".focus-workspace = "w0";
                "Mod+2".focus-workspace = "w1";
                "Mod+3".focus-workspace = "w2";
                "Mod+4".focus-workspace = "w3";
                "Mod+5".focus-workspace = "w4";
                "Mod+6".focus-workspace = "w5";
                "Mod+7".focus-workspace = "w6";
                "Mod+8".focus-workspace = "w7";
                "Mod+9".focus-workspace = "w8";
                "Mod+0".focus-workspace = "w9";

                "Mod+Shift+1".move-column-to-workspace = "w0";
                "Mod+Shift+2".move-column-to-workspace = "w1";
                "Mod+Shift+3".move-column-to-workspace = "w2";
                "Mod+Shift+4".move-column-to-workspace = "w3";
                "Mod+Shift+5".move-column-to-workspace = "w4";
                "Mod+Shift+6".move-column-to-workspace = "w5";
                "Mod+Shift+7".move-column-to-workspace = "w6";
                "Mod+Shift+8".move-column-to-workspace = "w7";
                "Mod+Shift+9".move-column-to-workspace = "w8";
                "Mod+Shift+0".move-column-to-workspace = "w9";

                "Mod+Space".spawn-sh = "${noctaliaExe} ipc call launcher toggle";
                "Mod+M".spawn-sh = "${config.pkgs.alsa-utils}/bin/amixer sset Capture toggle";

                "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
                "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

                "Mod+Ctrl+H".set-column-width = "50%";
                "Mod+Ctrl+L".set-column-width = "100%";
                "Mod+Ctrl+J".set-window-height = "50%";
                "Mod+Ctrl+K".set-window-height = "100%";

                "Mod+WheelScrollDown".focus-column-left = _: { };
                "Mod+WheelScrollUp".focus-column-right = _: { };
                "Mod+Ctrl+WheelScrollDown".focus-workspace-down = _: { };
                "Mod+Ctrl+WheelScrollUp".focus-workspace-up = _: { };

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
                  "w4" = settings;
                  "w5" = settings;
                  "w6" = settings;
                  "w7" = settings;
                  "w8" = settings;
                  "w9" = settings;
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
