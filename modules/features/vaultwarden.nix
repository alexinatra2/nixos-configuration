{ self, inputs, ... }:
{
  flake.nixosModules.vaultwarden =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      vaultwardenPort = 8222;
    in
    {
      options.local.vaultwarden = {
        domain = lib.mkOption {
          type = lib.types.str;
          default = "https://${config.networking.hostName}.REPLACE_WITH_YOUR_TAILNET.ts.net";
          description = "Public URL used by Vaultwarden clients inside the tailnet.";
        };

        environmentFiles = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Additional environment files passed to Vaultwarden, typically a sops-managed file containing ADMIN_TOKEN.";
        };
      };

      config = {
        services.vaultwarden = {
          enable = true;
          dbBackend = "sqlite";
          backupDir = "/var/backup/vaultwarden";
          environmentFile = config.local.vaultwarden.environmentFiles;
          config = {
            DOMAIN = config.local.vaultwarden.domain;
            SIGNUPS_ALLOWED = false;
            ROCKET_ADDRESS = "127.0.0.1";
            ROCKET_PORT = vaultwardenPort;
            ROCKET_LOG = "critical";
          };
        };

        systemd.services.tailscale-vaultwarden-serve = {
          description = "Expose Vaultwarden over Tailscale HTTPS";
          wantedBy = [ "multi-user.target" ];
          wants = [
            "tailscaled.service"
            "tailscaled-autoconnect.service"
            "vaultwarden.service"
          ];
          after = [
            "tailscaled.service"
            "tailscaled-autoconnect.service"
            "vaultwarden.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "tailscale-vaultwarden-serve-start" ''
              set -euo pipefail

              until ${pkgs.tailscale}/bin/tailscale status >/dev/null 2>&1; do
                sleep 2
              done

              ${pkgs.tailscale}/bin/tailscale serve --bg --https=443 --yes http://127.0.0.1:${toString vaultwardenPort}
            '';
            ExecStop = pkgs.writeShellScript "tailscale-vaultwarden-serve-stop" ''
              set -euo pipefail
              ${pkgs.tailscale}/bin/tailscale serve --https=443 --yes off || true
            '';
          };
        };
      };
    };
}
