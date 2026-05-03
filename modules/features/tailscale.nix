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
      hostTag = "tag:${config.networking.hostName}";
    in
    {
      sops.secrets."tailscale/authkey" = {
        restartUnits = [ "tailscaled-autoconnect.service" ];
      };

      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets."tailscale/authkey".path;

        extraUpFlags = [
          "--advertise-tags=${hostTag}"
        ];

        extraSetFlags = [
          "--operator=${operatorUser}"
        ];
      };
    };
}
