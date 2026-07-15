{ ... }:
{
  flake.nixosModules.eduroam =
    { config, lib, ... }:
    let
      cfg = config.local.eduroam;
    in
    {
      options.local.eduroam = {
        enable = lib.mkEnableOption "HTW Dresden eduroam profile";

        sopsFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Host-specific SOPS file containing the eduroam password.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.sopsFile != null;
            message = "The eduroam module requires local.eduroam.sopsFile when enabled.";
          }
          {
            assertion = config.networking.networkmanager.enable;
            message = "The eduroam module requires networking.networkmanager.enable.";
          }
        ];

        sops.secrets = {
          "eduroam/password".sopsFile = cfg.sopsFile;
        };

        networking.networkmanager.ensureProfiles = {
          profiles.eduroam = {
            connection = {
              autoconnect = true;
              autoconnect-priority = 100;
              id = "eduroam";
              type = "wifi";
            };

            wifi = {
              mode = "infrastructure";
              ssid = "eduroam";
            };

            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-eap";
            };

            "802-1x" = {
              anonymous-identity = "69873312454253036930@htw-dresden.de";
              eap = "ttls;";
              identity = "gxaco074@htw-dresden.de";
              password-flags = 1;
              phase2-auth = "pap";
            };

            ipv4.method = "auto";
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
          };

          secrets.entries = [
            {
              file = config.sops.secrets."eduroam/password".path;
              key = "password";
              matchId = "eduroam";
              matchSetting = "802-1x";
              trim = true;
            }
          ];
        };
      };
    };
}
