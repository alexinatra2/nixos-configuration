{ self, inputs, ... }:
{
  flake.nixosModules.nebula =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.local.nebula;
      networkName = "woodservant";
      serviceName = "nebula@${networkName}.service";
      hostName = config.networking.hostName;
      caSecret = "nebula/ca";
      certSecret = "nebula/${hostName}/cert";
      keySecret = "nebula/${hostName}/key";
    in
    {
      options.local.nebula.enable = lib.mkEnableOption "Woodservant Nebula network";

      config = lib.mkIf cfg.enable {
        sops.secrets = {
          ${caSecret} = {
            owner = "nebula-${networkName}";
            restartUnits = [ serviceName ];
          };
          ${certSecret} = {
            owner = "nebula-${networkName}";
            restartUnits = [ serviceName ];
          };
          ${keySecret} = {
            owner = "nebula-${networkName}";
            restartUnits = [ serviceName ];
          };
        };

        services.nebula.networks.${networkName} = {
          enable = true;
          ca = config.sops.secrets.${caSecret}.path;
          cert = config.sops.secrets.${certSecret}.path;
          key = config.sops.secrets.${keySecret}.path;
          lighthouses = [ "10.0.0.4" ];
          staticHostMap."10.0.0.4" = [ "178.105.193.80:443" ];
          tun.device = "nebula0";
          firewall = {
            inbound = [
              {
                port = "any";
                proto = "any";
                host = "any";
              }
            ];
            outbound = [
              {
                port = "any";
                proto = "any";
                host = "any";
              }
            ];
          };
        };

        networking.hosts = {
          "10.0.0.1" = [ "atlas.woodservant.com" ];
          "10.0.0.2" = [ "warden.woodservant.com" ];
          "10.0.0.3" = [ "sentinel.woodservant.com" ];
          "10.0.0.4" = [ "woodservant-prod.woodservant.com" ];
          "10.0.0.5" = [ "pixel.woodservant.com" ];
        };
      };
    };
}
