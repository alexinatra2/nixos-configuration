{
  self,
  ...
}:
{
  flake.nixosModules.monitorProfiles =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.monitorProfiles;
      escapeKanshiString = value: lib.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] value;
      renderOutput =
        name: output:
        lib.concatStringsSep "\n" (
          [
            "    output \"${escapeKanshiString name}\" {"
            "        ${if output.enable then "enable" else "disable"}"
          ]
          ++
            lib.optional (output.mode != null)
              "        mode ${
                        if output.mode == "preferred" then "preferred" else "\"${escapeKanshiString output.mode}\""
                      }"
          ++ lib.optional (
            output.position != null
          ) "        position ${toString output.position.x},${toString output.position.y}"
          ++ lib.optional (output.scale != null) "        scale ${toString output.scale}"
          ++ lib.optional (output.transform != null) "        transform \"${output.transform}\""
          ++
            lib.optional (output.adaptiveSync != null)
              "        adaptive_sync ${if output.adaptiveSync then "on" else "off"}"
          ++ [ "    }" ]
        );
      kanshiConfig = pkgs.writeText "kanshi-config" (
        lib.concatStringsSep "\n\n" (
          lib.mapAttrsToList (
            name: profile:
            "profile \"${escapeKanshiString name}\" {\n${lib.concatStringsSep "\n" (lib.mapAttrsToList renderOutput profile.outputs)}\n}"
          ) cfg.profiles
        )
        + "\n"
      );
    in
    {
      options.local.monitorProfiles = {
        enable = lib.mkEnableOption "automatic Kanshi monitor profiles";

        profiles = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options.outputs = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                      };

                      mode = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = "Output mode, or `preferred` to select its preferred mode.";
                      };

                      position = lib.mkOption {
                        type = lib.types.nullOr (
                          lib.types.submodule {
                            options = {
                              x = lib.mkOption { type = lib.types.int; };
                              y = lib.mkOption { type = lib.types.int; };
                            };
                          }
                        );
                        default = null;
                      };

                      scale = lib.mkOption {
                        type = lib.types.nullOr lib.types.float;
                        default = null;
                      };

                      transform = lib.mkOption {
                        type = lib.types.nullOr (
                          lib.types.enum [
                            "normal"
                            "90"
                            "180"
                            "270"
                            "flipped"
                            "flipped-90"
                            "flipped-180"
                            "flipped-270"
                          ]
                        );
                        default = null;
                      };

                      adaptiveSync = lib.mkOption {
                        type = lib.types.nullOr lib.types.bool;
                        default = null;
                      };
                    };
                  }
                );
              };
            }
          );
          default = { };
          description = "Kanshi profiles keyed by profile name.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.profiles != { };
            message = "local.monitorProfiles.profiles must define at least one profile.";
          }
        ];

        environment.systemPackages = [ pkgs.kanshi ];

        local.niri.extraStartupCommands = lib.mkAfter [
          [
            (lib.getExe pkgs.kanshi)
            "-c"
            kanshiConfig
          ]
        ];
      };
    };
}
