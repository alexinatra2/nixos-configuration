{ self, inputs, ... }:
{
  flake.nixosModules.tailscale =
    { config, ... }:
    {
      sops.secrets."tailscale/authkey" = {
        restartUnits = [ "tailscaled-autoconnect.service" ];
      };

      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets."tailscale/authkey".path;
      };
    };
}
