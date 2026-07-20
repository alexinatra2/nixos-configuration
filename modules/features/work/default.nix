{ self, ... }:
{
  flake.nixosModules.work =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.local.work.fernuni = {
        enable = lib.mkEnableOption "FernUni Hagen VPN manual command";

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
      };

      config = lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            devenv
            openconnect
            teams-for-linux
          ];

        }

        (lib.mkIf config.local.work.fernuni.enable (
          let
            fernuniCfg = config.local.work.fernuni;
            vpnConnectPackage = self.wrappers.fernuni-openconnect.wrap {
              inherit pkgs;
              configFile = config.sops.templates."vpn/fernuni/openconnect.conf".path;
            };
          in
          {
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

            sops.secrets = {
              "vpn/fernuni/password" = {
                sopsFile = fernuniCfg.sopsFile;
                restartUnits = [ "openconnect-fernuni.service" ];
              };
              "vpn/fernuni/totp-seed" = {
                sopsFile = fernuniCfg.sopsFile;
                restartUnits = [ "openconnect-fernuni.service" ];
              };
            };

            sops.useSystemdActivation = true;

            sops.templates."vpn/fernuni/token-secret" = {
              mode = "0400";
              content = ''
                base32:${config.sops.placeholder."vpn/fernuni/totp-seed"}
              '';
            };

            sops.templates."vpn/fernuni/openconnect.conf" = {
              mode = "0400";
              content = ''
                protocol=anyconnect
                user=${fernuniCfg.username}
                passwd-on-stdin
                useragent=AnyConnect
                token-mode=totp
                token-secret=@${config.sops.templates."vpn/fernuni/token-secret".path}
              '';
            };

            systemd.services."openconnect-fernuni" = {
              description = "FernUni OpenConnect VPN";
              wantedBy = lib.mkForce [ ];
              restartIfChanged = false;
              requires = [ "sops-install-secrets.service" ];
              wants = [ "network-online.target" ];
              after = [
                "NetworkManager.service"
                "network-online.target"
                "sops-install-secrets.service"
              ];
              serviceConfig = {
                Type = "simple";
                ExecStart = lib.getExe vpnConnectPackage;
                StandardInput = "file:${config.sops.secrets."vpn/fernuni/password".path}";
                ProtectHome = true;
                Restart = "on-failure";
                RestartSec = "15s";
              };
            };
          }
        ))
      ];
    };
}
