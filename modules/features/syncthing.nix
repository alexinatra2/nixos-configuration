{ self, inputs, ... }:
{
  flake.nixosModules.syncthing =
    {
      config,
      lib,
      ...
    }:
    {
      options.local.syncthing = {
        enable = lib.mkEnableOption "syncthing";

        guiUser = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Optional Syncthing GUI user name.";
        };

        devices = lib.mkOption {
          type = with lib.types; attrsOf attrs;
          default = { };
          description = "Syncthing devices for this host.";
        };

        folders = lib.mkOption {
          type = with lib.types; attrsOf attrs;
          default = { };
          description = "Syncthing folders for this host.";
        };

        secrets = {
          password = {
            name = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = "Optional SOPS secret name for the Syncthing GUI password file.";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root";
              description = "Owner for the Syncthing GUI password secret.";
            };
          };

          cert = {
            name = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = "Optional SOPS secret name for the Syncthing certificate.";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root";
              description = "Owner for the Syncthing certificate secret.";
            };
          };

          key = {
            name = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = "Optional SOPS secret name for the Syncthing key.";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root";
              description = "Owner for the Syncthing key secret.";
            };
          };
        };
      };

      config = lib.mkIf config.local.syncthing.enable {
        sops.secrets =
          lib.optionalAttrs (config.local.syncthing.secrets.password.name != null) {
            ${config.local.syncthing.secrets.password.name}.owner =
              config.local.syncthing.secrets.password.owner;
          }
          // lib.optionalAttrs (config.local.syncthing.secrets.cert.name != null) {
            ${config.local.syncthing.secrets.cert.name}.owner = config.local.syncthing.secrets.cert.owner;
          }
          // lib.optionalAttrs (config.local.syncthing.secrets.key.name != null) {
            ${config.local.syncthing.secrets.key.name}.owner = config.local.syncthing.secrets.key.owner;
          };

        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
          user = "alexander";
          group = "users";
          dataDir = "/home/alexander";
          guiPasswordFile = lib.mkIf (
            config.local.syncthing.secrets.password.name != null
          ) config.sops.secrets.${config.local.syncthing.secrets.password.name}.path;
          cert = lib.mkIf (
            config.local.syncthing.secrets.cert.name != null
          ) config.sops.secrets.${config.local.syncthing.secrets.cert.name}.path;
          key = lib.mkIf (
            config.local.syncthing.secrets.key.name != null
          ) config.sops.secrets.${config.local.syncthing.secrets.key.name}.path;

          settings = {
            gui = lib.optionalAttrs (config.local.syncthing.guiUser != null) {
              user = config.local.syncthing.guiUser;
            };
            devices = config.local.syncthing.devices;
            folders = config.local.syncthing.folders;
          };
        };
      };
    };
}
