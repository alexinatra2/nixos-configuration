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
      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";
        backupDir = "/var/backup/vaultwarden";
        environmentFile = [ config.sops.secrets."vaultwarden/env".path ];
        config = {
          DOMAIN = "https://warden.taila26075.ts.net";
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
}
