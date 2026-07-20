{ ... }:
{
  flake.wrappers.fernuni-openconnect =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options = {
        configFile = lib.mkOption {
          type = lib.types.str;
          default = "/run/secrets-rendered/vpn/fernuni/openconnect.conf";
          description = "Path to the FernUni OpenConnect configuration file.";
        };

        endpoint = lib.mkOption {
          type = lib.types.str;
          default = "vpn.fernuni-hagen.de";
          description = "FernUni VPN endpoint.";
        };
      };

      config = {
        package = lib.mkDefault pkgs.openconnect;
        exePath = "bin/openconnect";
        binName = "fernuni-openconnect";
        addFlag = [
          [
            "--config=${config.configFile}"
            config.endpoint
          ]
        ];
      };
    };
}
