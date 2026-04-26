{ self, ... }:
{
  flake.nixosModules.greeter =
    {
      config,
      ...
    }:
    {
      services.displayManager.sddm.enable = false;
      services.greetd.enable = false;

      services.displayManager.ly = {
        enable = true;
        settings = {
          animation = "colormix";
          colormix_col1 = "0x00${config.lib.stylix.colors.base08}";
          colormix_col2 = "0x00${config.lib.stylix.colors.base0B}";
          colormix_col3 = "0x00${config.lib.stylix.colors.base0A}";
          bigclock = true;
          clear_password = true;
          default_input = "session";
          hide_borders = true;
          shutdown_key = "F1";
          restart_key = "F2";
        };
      };

      services.displayManager.defaultSession = "niri";

    };
}
