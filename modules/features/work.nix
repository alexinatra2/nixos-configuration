{ self, inputs, ... }:
{
  flake.nixosModules.work =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.work;
      fernuniCfg = cfg.fernuni;
      username = config.local.base.username;
      vpnInterfaceName = "fernuni";
      runtimeDirectory = "/run/${vpnInterfaceName}-vpn";
      passwordFile = "${runtimeDirectory}/password";
      tokenSecretFile = "${runtimeDirectory}/token-secret";
      passwordSecretPath = config.sops.secrets.${fernuniCfg.passwordSecretName}.path;
      totpSeedSecretPath = config.sops.secrets.${fernuniCfg.totpSeedSecretName}.path;
      normalizeTotpSeedScript = pkgs.writeText "normalize-totp-seed.py" (
        builtins.readFile ./work/normalize-totp-seed.py
      );
      openconnectConfig = pkgs.writeText "${vpnInterfaceName}-openconnect.conf" ''
        protocol=anyconnect
        user=${fernuniCfg.username}
        passwd-on-stdin
        useragent=AnyConnect
        token-mode=totp
        token-secret=@${tokenSecretFile}
      '';
      vpnPreparationScript = pkgs.writeShellApplication {
        name = "fernuni-vpn-prepare";
        runtimeInputs = with pkgs; [
          coreutils
          python3Minimal
        ];
        text =
          lib.replaceStrings
            [
              "@passwordSecretPath@"
              "@passwordFile@"
              "@pythonExe@"
              "@normalizeTotpSeedScript@"
              "@totpSeedSecretPath@"
              "@tokenSecretFile@"
            ]
            [
              passwordSecretPath
              passwordFile
              (lib.getExe pkgs.python3Minimal)
              (toString normalizeTotpSeedScript)
              totpSeedSecretPath
              tokenSecretFile
            ]
            (builtins.readFile ./work/fernuni-vpn-prepare.sh);
      };
      vpnControlScript = pkgs.writeShellApplication {
        name = "fernuni-vpnctl";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          set -euo pipefail

          case "''${1-}" in
            up)
              exec systemctl start openconnect-${vpnInterfaceName}.service
              ;;
            down)
              exec systemctl stop openconnect-${vpnInterfaceName}.service
              ;;
            restart)
              exec systemctl restart openconnect-${vpnInterfaceName}.service
              ;;
            status)
              exec systemctl status openconnect-${vpnInterfaceName}.service --no-pager
              ;;
            logs)
              exec journalctl -u openconnect-${vpnInterfaceName}.service -n 100 --no-pager
              ;;
            *)
              printf 'Usage: %s <up|down|restart|status|logs>\n' "$0" >&2
              exit 1
              ;;
          esac
        '';
      };
      vpnCommand = pkgs.writeShellApplication {
        name = "fernuni-vpn";
        runtimeInputs = [ pkgs.sudo ];
        text = ''
          set -euo pipefail
          exec sudo ${lib.getExe vpnControlScript} "$@"
        '';
      };
    in
    {
      options.local.work = {
        specialisation.enable = lib.mkEnableOption "work boot specialisation";

        fernuni = {
          enable = lib.mkEnableOption "FernUni Hagen VPN manual command";

          gateway = lib.mkOption {
            type = lib.types.str;
            default = "vpn.fernuni-hagen.de";
            description = "FernUni OpenConnect gateway.";
          };

          username = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "FernUni VPN username.";
          };

          sopsFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Host-specific sops file containing FernUni VPN secrets.";
          };

          passwordSecretName = lib.mkOption {
            type = lib.types.str;
            default = "vpn/fernuni/password";
            description = "sops secret name for the FernUni VPN password.";
          };

          totpSeedSecretName = lib.mkOption {
            type = lib.types.str;
            default = "vpn/fernuni/totp-seed";
            description = "sops secret name for the FernUni TOTP seed or otpauth URI.";
          };
        };
      };

      config = lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            devenv
            openconnect
            teams-for-linux
          ];
        }

        (lib.mkIf cfg.specialisation.enable {
          specialisation.work.configuration = {
            system.nixos.tags = [ "work" ];
            local.tailscale.enable = lib.mkForce true;
          };
        })

        (lib.mkIf fernuniCfg.enable {
          assertions = [
            {
              assertion = fernuniCfg.username != "";
              message = "The work module requires local.work.fernuni.username when FernUni VPN support is enabled.";
            }
            {
              assertion = fernuniCfg.sopsFile != null;
              message = "The work module requires local.work.fernuni.sopsFile when FernUni VPN support is enabled.";
            }
          ];

          environment.systemPackages = [ vpnCommand ];

          sops.secrets = {
            "${fernuniCfg.passwordSecretName}".sopsFile = fernuniCfg.sopsFile;
            "${fernuniCfg.totpSeedSecretName}".sopsFile = fernuniCfg.sopsFile;
          };

          security.sudo.extraRules = [
            {
              users = [ username ];
              commands = map (
                subcommand: {
                  command = "${lib.getExe vpnControlScript} ${subcommand}";
                  options = [ "NOPASSWD" ];
                }
              ) [
                "up"
                "down"
                "restart"
                "status"
                "logs"
              ];
            }
          ];

          systemd.services."openconnect-${vpnInterfaceName}" = {
            description = "FernUni OpenConnect VPN";
            wantedBy = lib.mkForce [ ];
            restartIfChanged = false;
            wants = [ "network-online.target" ];
            after = [
              "NetworkManager.service"
              "network-online.target"
            ];
            serviceConfig = {
              Type = "simple";
              RuntimeDirectory = "${vpnInterfaceName}-vpn";
              RuntimeDirectoryMode = "0700";
              RuntimeDirectoryPreserve = "yes";
              UMask = "0077";
              ExecStartPre = lib.getExe vpnPreparationScript;
              ExecStart = "${lib.getExe pkgs.openconnect} --config=${openconnectConfig} ${fernuniCfg.gateway}";
              StandardInput = "file:${passwordFile}";
              ProtectHome = true;
              Restart = "on-failure";
              RestartSec = "15s";
            };
          };
        })
      ];
    };
}
