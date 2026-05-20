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
      snapshotDir = "/home/alexander/Documents/Backups/Vaultwarden";
      snapshotScript = pkgs.writeShellScript "vaultwarden-snapshot" ''
        set -euo pipefail

        export PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.findutils
            pkgs.sqlite
          ]
        }

        install -d -m 0750 -o alexander -g users "${snapshotDir}"

        snapshot_path="${snapshotDir}/db-$(date -u +%Y%m%dT%H%M%SZ).sqlite3"
        sqlite3 /var/lib/bitwarden_rs/db.sqlite3 ".backup '$snapshot_path'"
        chown alexander:users "$snapshot_path"

        find "${snapshotDir}" -maxdepth 1 -type f -name 'db-*.sqlite3' -printf '%T@ %p\n' \
          | sort -n \
          | head -n -30 \
          | cut -d' ' -f2- \
          | while IFS= read -r old_snapshot; do
              rm -f "$old_snapshot"
            done
      '';
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

          SMTP_HOST = "smtp.purelymail.com";
          SMTP_PORT = 465;
          SMTP_SECURITY = "force_tls";
          SMTP_FROM = "alexander@woodservant.com";
          SMTP_FROM_NAME = "Vaultwarden";
          SMTP_USERNAME = "alexander@woodservant.com";

          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = vaultwardenPort;
          ROCKET_LOG = "critical";
        };
      };

      systemd.tmpfiles.rules = [
        "d ${snapshotDir} 0750 alexander users -"
      ];

      systemd.services.vaultwarden-snapshot = {
        description = "Create periodic Vaultwarden database snapshots";
        after = [ "vaultwarden.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = snapshotScript;
        };
      };

      systemd.timers.vaultwarden-snapshot = {
        description = "Run the Vaultwarden snapshot job";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "1h";
          Persistent = true;
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
