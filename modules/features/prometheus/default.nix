{ self, inputs, ... }:
{
  flake.nixosModules.prometheus =
    {
      config,
      lib,
      ...
    }:
    {
      options.local.prometheus = {
        enable = lib.mkEnableOption "Prometheus node exporter";

        listenAddress = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Address for the node exporter to listen on.";
        };

        enabledCollectors = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ "systemd" ];
          description = "Additional node exporter collectors to enable.";
        };

        extraFlags = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Extra command line flags for the node exporter.";
        };

        tailscaleScrape = {
          enable = lib.mkEnableOption "Tailscale-restricted node exporter scraping";

          interface = lib.mkOption {
            type = lib.types.str;
            default = "tailscale0";
            description = "Network interface allowed to scrape the node exporter.";
          };
        };
      };

      config = lib.mkIf config.local.prometheus.enable {
        services.prometheus.exporters.node = {
          enable = true;
          inherit (config.local.prometheus)
            listenAddress
            enabledCollectors
            extraFlags
            ;
        };

        networking.firewall.interfaces = lib.mkIf config.local.prometheus.tailscaleScrape.enable {
          ${config.local.prometheus.tailscaleScrape.interface}.allowedTCPPorts = [
            config.services.prometheus.exporters.node.port
          ];
        };
      };
    };
}
