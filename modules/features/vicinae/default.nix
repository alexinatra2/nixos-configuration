{ ... }:
{
  flake.nixosModules.vicinae =
    { lib, pkgs, config, ... }:
    {
      options.local.vicinae.enable = lib.mkEnableOption "vicinae launcher";

      config = lib.mkIf config.local.vicinae.enable {
        environment.systemPackages = [ pkgs.vicinae ];

        local.niri.bindings."Mod+Space".spawn = [ (lib.getExe pkgs.vicinae) "toggle" ];
        local.niri.extraStartupCommands = lib.mkAfter [
          [ "${lib.getExe pkgs.vicinae}" "server" ]
        ];
      };
    };
}
