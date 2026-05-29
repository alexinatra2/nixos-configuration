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
      vaultwardenHost = config.local.tailscale.fqdn;
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
        sqlite3 /var/lib/vaultwarden/db.sqlite3 ".backup '$snapshot_path'"
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
      assertions = [
        {
          assertion = config.local.tailscale.fqdn != null;
          message = "The vaultwarden module requires local.tailscale.expectedTailnet to compute its MagicDNS name.";
        }
      ];

      sops.secrets = {
        "vaultwarden/tls/cert" = {
          owner = "nginx";
          group = "nginx";
          mode = "0440";
          restartUnits = [ "nginx.service" ];
          sopsFile = ../../hosts/warden/secrets.yaml;
        };

        "vaultwarden/tls/key" = {
          owner = "nginx";
          group = "nginx";
          mode = "0440";
          restartUnits = [ "nginx.service" ];
          sopsFile = ../../hosts/warden/secrets.yaml;
        };
      };

      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";
        backupDir = "/var/backup/vaultwarden";
        environmentFile = [ config.sops.secrets."vaultwarden/env".path ];
        config = {
          DOMAIN = "https://${vaultwardenHost}";
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

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts.${vaultwardenHost} = {
          onlySSL = true;
          sslCertificate = config.sops.secrets."vaultwarden/tls/cert".path;
          sslCertificateKey = config.sops.secrets."vaultwarden/tls/key".path;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString vaultwardenPort}";
            proxyWebsockets = true;
          };
        };
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 443 ];

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

    };
}
