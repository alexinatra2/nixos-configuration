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

      runtimeTools = with pkgs; [
        openssh
        playerctl
        podman
        pulseaudio
        power-profiles-daemon
      ];

      jsonFormat = pkgs.formats.json { };
      baseSettings = lib.recursiveUpdate {
        keybinding = "emacs";
        providers = {
          "@Gelei/vicinae-extension-bluetooth-0".preferences.connectionToggleable = true;
          "@leiserfg/vicinae-extension-ssh-0".preferences.terminal = lib.getExe pkgs.kitty;
          "@mrmartineau/search-npm".preferences.defaultCopyAction = "pnpm";
          "@samlinville/tailscale".preferences.tailscalePath = lib.getExe pkgs.tailscale;
        };
      } cfg.settings;
      settingsFile = jsonFormat.generate "vicinae-settings.json" (
        baseSettings
        // {
          imports =
            (baseSettings.imports or [ ]) ++ lib.optional (cfg.githubTokenSopsFile != null) githubSettings.path;
        }
      );

      githubSettings = config.sops.templates."vicinae/github-settings";
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

        settings = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          description = "Additional Vicinae settings merged into the generated settings file.";
        };
      };

      config = lib.mkIf cfg.enable {
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

        sops.secrets."vicinae/github-token" = lib.mkIf (cfg.githubTokenSopsFile != null) {
          sopsFile = cfg.githubTokenSopsFile;
          owner = username;
        };
        sops.templates."vicinae/github-settings" = lib.mkIf (cfg.githubTokenSopsFile != null) {
          owner = username;
          mode = "0600";
          content = builtins.toJSON {
            providers."@knoopx/vicinae-extension-github-0".preferences.personalAccessToken =
              config.sops.placeholder."vicinae/github-token";
          };
        };
      };
    };
}
