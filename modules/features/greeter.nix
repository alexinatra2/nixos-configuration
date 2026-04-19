{ self, ... }:
{
  flake.nixosModules.greeter =
    {
      pkgs,
      lib,
      ...
    }:
    {
      services.displayManager.sddm.enable = false;
      services.greetd.enable = false;

      services.displayManager.ly = {
        enable = true;
        settings = {
          animation = "matrix";
          bigclock = true;
          clear_password = true;
          default_input = "session";
          hide_borders = true;
          shutdown_key = "F1";
          restart_key = "F2";
        };
      };

      services.displayManager.defaultSession = "niri";

      specialisation = {
        tuigreet.configuration = {
          services.displayManager.ly.enable = lib.mkForce false;
          services.greetd = {
            enable = lib.mkForce true;
            useTextGreeter = true;
            settings = {
              default_session = {
                user = "greeter";
                command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --cmd niri-session";
              };
            };
          };
        };

        sddm.configuration = {
          services.greetd.enable = lib.mkForce false;
          services.displayManager.ly.enable = lib.mkForce false;
          services.displayManager.sddm = {
            enable = lib.mkForce true;
            wayland.enable = true;
          };
        };

        ly.configuration = {
          services.greetd.enable = lib.mkForce false;
          services.displayManager.ly.enable = lib.mkForce true;
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
}
