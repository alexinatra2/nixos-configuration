{
  programs.niri.settings = {
    prefer-no-csd = true;

    layout.focus-ring.width = 2;

    input = {
      keyboard = {
        repeat-delay = 250;
        repeat-rate = 25;
      };
      touchpad.natural-scroll = true;
      mouse.natural-scroll = false;
      focus-follows-mouse.enable = true;
    };

    outputs = {
      "eDP-1" = {
        mode = {
          width = 2880;
          height = 1800;
        };
      };
      "DVI-I-2" = {
        mode = {
          width = 2976;
          height = 1674;
        };
      };
      "DVI-I-1" = {
        mode = {
          width = 2976;
          height = 1674;
        };
      };
    };

    environment = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "niri";
      DISPLAY = ":0";
    };
  };
}
