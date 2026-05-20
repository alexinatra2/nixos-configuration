{ self, inputs, ... }:
let
  hostName = "warden";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      user-alexander
      shell
      sops
      tailscale
      syncthing
      vaultwarden
      warden
    ];
  };
}
