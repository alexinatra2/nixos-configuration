{ self, inputs, ... }:
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
      preferences = config.local.agentPreferences;
      hermesCfg = config.services.hermes-agent;
      hermesHome = "${hermesCfg.stateDir}/.hermes";
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
        self.nixosModules.agentPreferences
        inputs.hermes-agent.nixosModules.default
      ];

      options.local.hermes = {
        enable = lib.mkEnableOption "Hermes Agent";

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
      ];
    };
}
