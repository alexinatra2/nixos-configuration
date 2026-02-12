{
  config,
  lib,
  ...
}:

let
  cfg = config.plasmaOverrides;
in
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

  config = lib.mkIf cfg.enable {
    xdg.configFile."kcminputrc" = {
      # make sure file gets overridden
      force = true;
      text = ''
        [Keyboard]
        RepeatDelay=${toString cfg.keyboard.repeatDelay}
        RepeatRate=${toString cfg.keyboard.repeatRate}

        [Libinput]
        NaturalScroll=true
        ScrollFactor=${toString cfg.touchpad.scrollFactor}
      '';
    };
  };
}
