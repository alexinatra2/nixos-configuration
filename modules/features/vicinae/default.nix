{ ... }:
{
  flake.nixosModules.vicinae =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      username = config.local.base.username;
      homeDirectory = config.local.base.homeDirectory;
      screenshotExtension = pkgs.buildNpmPackage {
        pname = "vicinae-screenshot";
        version = "0";
        src = ./screenshot;
        npmDepsHash = "sha256-mE+2Ab/SIg9+t6cgfwWOMkTaRIZ5CIcYSLYoQKkDOcY=";

        buildPhase = ''
          runHook preBuild
          npm run typecheck
          npm run build -- --out=$out
          runHook postBuild
        '';
        dontNpmInstall = true;
      };
      settingsFile = (pkgs.formats.json { }).generate "vicinae-settings.json" {
        keybinding = "emacs";
      };
      configuredVicinae = pkgs.symlinkJoin {
        name = "${pkgs.vicinae.name}-configured";
        paths = [ pkgs.vicinae ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/vicinae" \
            --set VICINAE_OVERRIDES "${settingsFile}"
        '';
        inherit (pkgs.vicinae) meta;
      };
    in
    {
      options.local.vicinae.enable = lib.mkEnableOption "vicinae launcher";

      config = lib.mkIf config.local.vicinae.enable {
        environment.systemPackages = [ configuredVicinae ];

        local.niri.bindings."Mod+Space".spawn = [
          (lib.getExe configuredVicinae)
          "toggle"
        ];
        local.niri.bindings."Mod+S".spawn = [
          (lib.getExe configuredVicinae)
          "vicinae://launch/@alexander/screenshot/screenshot"
        ];
        local.niri.extraStartupCommands = lib.mkAfter [
          [
            "${lib.getExe configuredVicinae}"
            "server"
          ]
        ];

        systemd.tmpfiles.rules = [
          "d ${homeDirectory}/.local/share/vicinae/extensions 0755 ${username} users -"
          "L+ ${homeDirectory}/.local/share/vicinae/extensions/screenshot - - - - ${screenshotExtension}"
        ];
      };
    };
}
