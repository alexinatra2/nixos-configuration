{ ... }:
{
  flake.nixosModules.focusrite =
    { config, lib, pkgs, ... }:
    let
      cfg = config.local.focusrite;
      profiles = let
        entries = builtins.readDir ./.;
        stateFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".state" name) entries;
      in map (lib.removeSuffix ".state") (builtins.attrNames stateFiles);
      focusriteProfileBin = pkgs.writeShellApplication {
        name = "focusrite-profile";
        runtimeInputs = [ pkgs.alsa-utils ];
        text = ''
          set -euo pipefail
          profile="''${1:-}"
          case "$profile" in
            ${lib.concatStringsSep "|" profiles})
              exec alsactl restore -f "${./.}/$profile.state"
              ;;
            *)
              echo "Usage: focusrite-profile <${lib.concatStringsSep "|" profiles}>" >&2
              exit 1
              ;;
          esac
        '';
      };
      focusritePicker = pkgs.writeShellApplication {
        name = "focusrite-picker";
        runtimeInputs = [ pkgs.vicinae ];
        text = ''
          set -euo pipefail
          profile=$(
            echo -e '${lib.concatStringsSep "\\n" profiles}' \
              | vicinae dmenu --placeholder "Select Focusrite profile"
          )
          ${lib.getExe focusriteProfileBin} "$profile"
        '';
      };
    in
    {
      options.local.focusrite = {
        enable = lib.mkEnableOption "Focusrite Scarlett profile management";

        defaultProfile = lib.mkOption {
          type = lib.types.enum profiles;
          default = "direct";
          description = "Focusrite profile to restore on login.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages =
          [ focusriteProfileBin focusritePicker ]
          ++ (map (profile:
            pkgs.writeShellScriptBin "focusrite-${profile}" ''
              exec ${lib.getExe focusriteProfileBin} ${profile}
            ''
          ) profiles);

        systemd.user.services."focusrite-profile@" = {
          description = "Apply Focusrite Scarlett profile %i";
          after = [ "pipewire.service" "wireplumber.service" ];
          wants = [ "pipewire.service" "wireplumber.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${lib.getExe focusriteProfileBin} %i";
          };
        };

        local.niri.extraStartupCommands = [
          [ "${lib.getExe focusriteProfileBin}" cfg.defaultProfile ]
        ];

        local.niri.bindings."Mod+P".spawn = lib.getExe focusritePicker;

      };
    };
}
