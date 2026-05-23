{ self, inputs, ... }:
{
  flake.nixosModules.tailscale =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.local.tailscale;
      normalUsers = lib.attrNames (
        lib.filterAttrs (_: userCfg: userCfg.isNormalUser or false) config.users.users
      );

      operatorUser = if normalUsers == [ ] then "root" else builtins.head normalUsers;
      resolvedAuthKeyFile =
        if cfg.authKeyFile != null then
          cfg.authKeyFile
        else if cfg.authKeySecretName != null then
          config.sops.secrets.${cfg.authKeySecretName}.path
        else
          null;
    in
    {
      options.local.tailscale = {
        enable = lib.mkEnableOption "Tailscale client enrollment";

        authKeyFile = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Absolute path to the Tailscale or Headscale auth key file.";
        };

        authKeySecretName = lib.mkOption {
          type = with lib.types; nullOr str;
          default = "tailscale/authkey";
          description = "SOPS secret name containing the auth key when authKeyFile is not set.";
        };

        hostname = lib.mkOption {
          type = with lib.types; str;
          default = config.networking.hostName;
          description = "Hostname to register with the selected control plane.";
        };

        loginServer = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          example = "https://headscale.woodservant.com";
          description = "Login server URL. Leave null for hosted Tailscale.";
        };

        expectedTailnet = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          example = "tailnet.woodservant.com";
          description = "Expected MagicDNS base domain for this host's selected tailnet.";
        };

        fqdn = lib.mkOption {
          type = with lib.types; nullOr str;
          description = "Computed MagicDNS FQDN for this host on the selected tailnet.";
        };

        tags = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ "tag:${config.networking.hostName}" ];
          description = "Tailscale tags advertised by this host.";
        };
      };

      config = lib.mkIf cfg.enable {
        local.tailscale.fqdn =
          if cfg.expectedTailnet == null then null else "${cfg.hostname}.${cfg.expectedTailnet}";

        sops.secrets = lib.optionalAttrs (cfg.authKeySecretName != null) {
          ${cfg.authKeySecretName} = {
            restartUnits = [ "tailscaled-autoconnect.service" ];
          };
        };

        services.tailscale = {
          enable = true;
          authKeyFile = resolvedAuthKeyFile;

          extraUpFlags =
            lib.optional (cfg.hostname != "") "--hostname=${cfg.hostname}"
            ++ lib.optional (cfg.loginServer != null) "--login-server=${cfg.loginServer}"
            ++ lib.optional (cfg.tags != [ ]) "--advertise-tags=${lib.concatStringsSep "," cfg.tags}";

          extraSetFlags = [
            "--operator=${operatorUser}"
          ];
        };
      };
    };
}
