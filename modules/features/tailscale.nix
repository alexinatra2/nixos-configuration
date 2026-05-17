{ self, inputs, ... }:
{
  flake.nixosModules.tailscale =
    {
      config,
      lib,
      ...
    }:
    let
      normalUsers = lib.attrNames (
        lib.filterAttrs (_: userCfg: userCfg.isNormalUser or false) config.users.users
      );

      operatorUser = if normalUsers == [ ] then "root" else builtins.head normalUsers;
    in
    {
      options.local.tailscale.tags = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ "tag:${config.networking.hostName}" ];
        description = "Tailscale tags advertised by this host.";
      };

      config = {
        sops.secrets."tailscale/authkey" = {
          restartUnits = [ "tailscaled-autoconnect.service" ];
        };

        services.tailscale = {
          enable = true;
          authKeyFile = config.sops.secrets."tailscale/authkey".path;

          extraUpFlags = lib.optional (config.local.tailscale.tags != [ ]) (
            "--advertise-tags=${lib.concatStringsSep "," config.local.tailscale.tags}"
          );

          extraSetFlags = [
            "--operator=${operatorUser}"
          ];
        };
      };
    };
}
