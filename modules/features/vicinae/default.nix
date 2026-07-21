{ inputs, ... }:
{
  flake.nixosModules.vicinae =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.vicinae;
      username = config.local.base.username;
      homeDirectory = config.local.base.homeDirectory;
      system = pkgs.stdenv.hostPlatform.system;

      vicinaePkg = inputs.vicinae.packages.${system}.default;
      vicinaeLib = inputs.vicinae.lib.${system};
      raycastRevision = "72a77c5c9767259911f27c7a806f3486be5f1b85";
      extensions = import ./extensions.nix {
        inherit
          inputs
          pkgs
          raycastRevision
          vicinaeLib
          ;
      };
      settingsComponent = import ./settings.nix { inherit lib pkgs; };
      credentials = import ./credentials.nix {
        inherit config lib username;
        githubSopsFile = cfg.githubTokenSopsFile;
        bitwardenSopsFile = cfg.bitwardenCredentialsSopsFile;
      };

      runtimeTools = with pkgs; [
        bitwarden-cli
        openssh
        playerctl
        podman
        pulseaudio
        power-profiles-daemon
      ];

      settingsFile = settingsComponent.generate {
        userSettings = cfg.settings;
        secretImports = credentials.settingsImports;
      };
      configuredVicinae = pkgs.symlinkJoin {
        name = "${vicinaePkg.name}-configured";
        paths = [ vicinaePkg ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/vicinae" \
            --prefix PATH : ${lib.makeBinPath runtimeTools} \
            --set VICINAE_OVERRIDES "${settingsFile}"
        '';
        inherit (vicinaePkg) meta;
      };
    in
    {
      options.local.vicinae = {
        enable = lib.mkEnableOption "vicinae launcher";

        githubTokenSopsFile = lib.mkOption {
          type = with lib.types; nullOr path;
          default = null;
          description = "SOPS file containing vicinae/github-token.";
        };

        bitwardenCredentialsSopsFile = lib.mkOption {
          type = with lib.types; nullOr path;
          default = null;
          description = "SOPS file containing the Vicinae Bitwarden API credentials.";
        };

        settings = lib.mkOption {
          inherit (settingsComponent.format) type;
          default = { };
          description = "Additional Vicinae settings merged into the generated settings file.";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            nix.settings = {
              extra-substituters = [ "https://vicinae.cachix.org" ];
              extra-trusted-public-keys = [
                "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
              ];
            };

            security.wrappers.vicinae-input-server = {
              source = "${vicinaePkg}/libexec/vicinae/vicinae-input-server";
              capabilities = "cap_dac_override+ep";
              owner = "root";
              group = "root";
            };

            environment.systemPackages = [ configuredVicinae ] ++ runtimeTools;

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
                (lib.getExe configuredVicinae)
                "server"
              ]
            ];

            systemd.tmpfiles.rules = [
              "d ${homeDirectory}/.local/share/vicinae/extensions 0755 ${username} users -"
            ]
            ++ map (
              extension:
              "L+ ${homeDirectory}/.local/share/vicinae/extensions/${extension.installName} - - - - ${extension.package}"
            ) extensions;
          }
          credentials.nixosConfig
        ]
      );
    };
}
