{ ... }:
{
  flake.nixosModules.focusrite =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.focusrite;
      username = config.local.base.username;
      homeDirectory = config.local.base.homeDirectory;
      profiles =
        let
          entries = builtins.readDir ./.;
          stateFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".state" name) entries;
        in
        map (lib.removeSuffix ".state") (builtins.attrNames stateFiles);
      profilePreviews = map (
        profile:
        let
          preview = ./. + "/${profile}.jpg";
        in
        assert lib.assertMsg (builtins.pathExists preview) "Missing Focusrite preview: ${toString preview}";
        {
          name = "${profile}.jpg";
          path = builtins.path {
            path = preview;
            name = "focusrite-${profile}.jpg";
          };
        }
      ) profiles;
      focusriteExtensionSource = pkgs.runCommand "vicinae-focusrite-source" { } ''
        cp -r ${./vicinae} "$out"
        chmod -R u+w "$out"
        cp ${../vicinae/screenshot/package-lock.json} "$out/package-lock.json"
        mkdir -p "$out/assets"
        ${lib.concatMapStringsSep "\n" (
          preview: ''cp ${preview.path} "$out/assets/${preview.name}"''
        ) profilePreviews}
      '';
      focusriteExtension = pkgs.buildNpmPackage {
        pname = "vicinae-focusrite";
        version = "0";
        src = focusriteExtensionSource;
        npmDepsHash = "sha256-mE+2Ab/SIg9+t6cgfwWOMkTaRIZ5CIcYSLYoQKkDOcY=";

        buildPhase = ''
          runHook preBuild
          npm run typecheck
          npm run build -- --out=$out
          runHook postBuild
        '';
        dontNpmInstall = true;
      };
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
          exec vicinae vicinae://launch/@alexander/focusrite/profiles
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
        environment.systemPackages = [
          focusriteProfileBin
          focusritePicker
        ]
        ++ (map (
          profile:
          pkgs.writeShellScriptBin "focusrite-${profile}" ''
            exec ${lib.getExe focusriteProfileBin} ${profile}
          ''
        ) profiles);

        systemd.user.services."focusrite-profile@" = {
          description = "Apply Focusrite Scarlett profile %i";
          after = [
            "pipewire.service"
            "wireplumber.service"
          ];
          wants = [
            "pipewire.service"
            "wireplumber.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${lib.getExe focusriteProfileBin} %i";
          };
        };

        systemd.tmpfiles.rules = [
          "L+ ${homeDirectory}/.local/share/vicinae/extensions/focusrite - - - - ${focusriteExtension}"
        ];

        local.niri.extraStartupCommands = [
          [
            "${lib.getExe focusriteProfileBin}"
            cfg.defaultProfile
          ]
        ];

        local.niri.bindings."Mod+P".spawn = lib.getExe focusritePicker;

      };
    };
}
