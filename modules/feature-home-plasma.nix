{
  flake.modules.homeManager.plasma =
    { config, lib, ... }:
    {
      options.plasmaOverrides = {
        enable = lib.mkEnableOption "Enable KDE Plasma configuration";

        keyboard = {
          repeatDelay = lib.mkOption {
            type = lib.types.int;
            default = 250;
            description = "Key repeat delay in milliseconds before repeating starts";
          };
          repeatRate = lib.mkOption {
            type = lib.types.int;
            default = 25;
            description = "Number of key repeats per second";
          };
        };

        touchpad = {
          scrollFactor = lib.mkOption {
            type = lib.types.float;
            default = 1.5;
            description = "Touchpad scroll factor (scroll speed)";
          };
        };
      };

      config = lib.mkIf config.plasmaOverrides.enable {
        xdg.configFile."kcminputrc" = {
          force = true;
          text = ''
            [Keyboard]
            RepeatDelay=${toString config.plasmaOverrides.keyboard.repeatDelay}
            RepeatRate=${toString config.plasmaOverrides.keyboard.repeatRate}

            [Libinput]
            NaturalScroll=true
            ScrollFactor=${toString config.plasmaOverrides.touchpad.scrollFactor}
          '';
        };
      };
    };
}
