{ ... }:
{
  flake.nixosModules.vicinae =
    { lib, pkgs, config, ... }:
    let
      cfg = config.local.vicinae;
      vicinaeDmenu = pkgs.writeShellApplication {
        name = "vicinae-dmenu";
        runtimeInputs = [ pkgs.vicinae ];
        text = ''
          entries=${
            lib.concatStringsSep "\n" (
              map (app: "${lib.escapeShellArg app.name}\t${lib.escapeShellArg app.command}") cfg.applications
            )
          }
          selection=$(echo "$entries" | vicinae dmenu --placeholder "Select action")
          [ -z "$selection" ] && exit 0
          cmd=$(echo "$selection" | awk -F'\t' '{print $2}')
          exec sh -c "$cmd"
        '';
      };
    in
    {
      options.local.vicinae = {
        enable = lib.mkEnableOption "vicinae launcher";

        applications = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Display name in the vicinae dmenu.";
              };
              command = lib.mkOption {
                type = lib.types.str;
                description = "Shell command to execute when selected.";
              };
            };
          });
          default = [ ];
          description = "Applications for the vicinae dmenu launcher.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.vicinae vicinaeDmenu ];

        local.niri.bindings."Mod+Space".spawn = lib.getExe vicinaeDmenu;
        local.niri.extraStartupCommands = lib.mkAfter [
          [ "${lib.getExe pkgs.vicinae}" "server" ]
        ];
      };
    };
}
