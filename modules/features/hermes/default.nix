{ inputs, ... }:
{
  flake.nixosModules.hermes =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.hermes;
      goeranhCfg = cfg.goeranh;
      preferences = config.local.agentPreferences;
      hermesCfg = config.services.hermes-agent;
      hermesHome = "${hermesCfg.stateDir}/.hermes";
      goeranhModel = "deepreinforce-ai/Ornith-1.0-35B-GGUF:Q4_K_M";
      goeranhSecretName = "hermes/goeranh-token";
      hermesPackage =
        if hermesCfg.extraPythonPackages == [ ] && hermesCfg.extraDependencyGroups == [ ] then
          hermesCfg.package
        else
          hermesCfg.package.override {
            inherit (hermesCfg) extraPythonPackages extraDependencyGroups;
          };
    in
    {
      imports = [
        inputs.hermes-agent.nixosModules.default
      ];

      options.local.hermes = {
        enable = lib.mkEnableOption "Hermes Agent";

        interactive = {
          enable = lib.mkEnableOption "shared Hermes CLI access for the primary user";

          user = lib.mkOption {
            type = lib.types.str;
            default = config.local.base.username;
            description = "User granted access to the service-managed Hermes state.";
          };
        };

        dashboard = {
          enable = lib.mkEnableOption "the loopback-only Hermes dashboard";

          port = lib.mkOption {
            type = lib.types.port;
            default = 9119;
            description = "Loopback port for the Hermes dashboard.";
          };

          endpoint = lib.mkOption {
            type = lib.types.str;
            readOnly = true;
            default = "http://127.0.0.1:${toString cfg.dashboard.port}";
            description = "Loopback endpoint for a host-owned reverse proxy.";
          };
        };

        goeranh = {
          enable = lib.mkEnableOption "the Goeranh Hermes provider";

          sopsFile = lib.mkOption {
            type = lib.types.path;
            description = "SOPS file containing the Goeranh API token.";
          };

          sopsKey = lib.mkOption {
            type = lib.types.str;
            default = "opencode/goeranh-token";
            description = "Key containing the Goeranh API token in the SOPS file.";
          };
        };
      };

      config = lib.mkMerge [
        {
          assertions = [
            {
              assertion = !cfg.dashboard.enable || cfg.enable;
              message = "local.hermes.dashboard.enable requires local.hermes.enable.";
            }
            {
              assertion = !cfg.dashboard.enable || !hermesCfg.container.enable;
              message = "local.hermes.dashboard.enable supports only native Hermes deployments.";
            }
            {
              assertion = !cfg.interactive.enable || cfg.enable;
              message = "local.hermes.interactive.enable requires local.hermes.enable.";
            }
            {
              assertion = !goeranhCfg.enable || cfg.enable;
              message = "local.hermes.goeranh.enable requires local.hermes.enable.";
            }
          ];
        }

        (lib.mkIf cfg.enable {
          services.hermes-agent = {
            enable = true;
            settings = {
              agent.system_prompt = preferences.policy.text;
            }
            // lib.optionalAttrs (preferences.skillDirectories != [ ]) {
              skills.external_dirs = map toString preferences.skillDirectories;
            };
          };

          systemd.tmpfiles.rules = [
            "L+ ${hermesHome}/SOUL.md - - - - ${preferences.identity.file}"
          ];

          systemd.services.hermes-dashboard = lib.mkIf cfg.dashboard.enable {
            description = "Hermes Agent dashboard";
            wantedBy = [ "multi-user.target" ];
            wants = [
              "hermes-agent.service"
              "network-online.target"
            ];
            after = [
              "network-online.target"
              "hermes-agent.service"
            ];

            environment = {
              HOME = hermesCfg.stateDir;
              HERMES_HOME = hermesHome;
              HERMES_MANAGED = "true";
            };

            path = [
              hermesPackage
              pkgs.bash
              pkgs.coreutils
              pkgs.git
            ]
            ++ hermesCfg.extraPackages;

            serviceConfig = {
              User = hermesCfg.user;
              Group = hermesCfg.group;
              WorkingDirectory = hermesCfg.workingDirectory;
              ExecStart = "${hermesPackage}/bin/hermes dashboard --host 127.0.0.1 --port ${toString cfg.dashboard.port} --no-open";
              Restart = "on-failure";
              RestartSec = 5;
              UMask = "0007";
              NoNewPrivileges = true;
              ProtectSystem = "strict";
              ProtectHome = false;
              ReadWritePaths = [
                hermesCfg.stateDir
                hermesCfg.workingDirectory
              ];
              PrivateTmp = true;
            };
          };
        })

        (lib.mkIf (cfg.enable && cfg.interactive.enable) {
          services.hermes-agent.addToSystemPackages = true;
          users.users.${cfg.interactive.user}.extraGroups = [ hermesCfg.group ];
        })

        (lib.mkIf (cfg.enable && goeranhCfg.enable) {
          services.hermes-agent.settings = {
            providers.goeranh = {
              name = "Goeranh";
              api = "https://ai.goeranh.de/v1";
              key_env = "GOERANH_API_KEY";
              transport = "chat_completions";
              default_model = goeranhModel;
              models.${goeranhModel}.context_length = 256000;
            };

            model = {
              provider = "custom:goeranh";
              default = goeranhModel;
              max_tokens = 65536;
            };
          };

          systemd.services = lib.mkIf config.sops.useSystemdActivation {
            hermes-agent = {
              requires = [ "sops-install-secrets.service" ];
              after = [ "sops-install-secrets.service" ];
            };

            hermes-dashboard = lib.mkIf cfg.dashboard.enable {
              requires = [ "sops-install-secrets.service" ];
              after = [ "sops-install-secrets.service" ];
            };
          };

          sops.secrets.${goeranhSecretName} = {
            inherit (goeranhCfg) sopsFile;
            key = goeranhCfg.sopsKey;
            owner = hermesCfg.user;
            group = hermesCfg.group;
            mode = "0400";
          };

          sops.templates."hermes/env" = {
            path = "${hermesHome}/.env";
            owner = hermesCfg.user;
            group = hermesCfg.group;
            mode = if cfg.interactive.enable then "0440" else "0400";
            restartUnits = [
              "hermes-agent.service"
            ]
            ++ lib.optional cfg.dashboard.enable "hermes-dashboard.service";
            content = ''
              GOERANH_API_KEY=${config.sops.placeholder.${goeranhSecretName}}
            '';
          };
        })
      ];
    };
}
