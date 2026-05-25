{ self, inputs, ... }:
let
  hostName = "warden";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hostBase
      prometheus
      user-alexander
      shell
      tailscale
      syncthing
      vaultwarden
      warden
    ];
  };
}
