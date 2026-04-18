{ self, inputs, ... }:
let
  username = "alexander";
in
{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      hardware.graphics.enable32Bit = true;

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
      };

      programs = {
        steam = {
          enable = true;
          gamescopeSession.enable = true;
        };

        gamemode.enable = true;
        gamescope = {
          enable = true;
          capSysNice = true;
        };
      };

      environment.systemPackages = with pkgs; [
        mangohud
        protonup-qt
        steam-run
      ];
    };
}
