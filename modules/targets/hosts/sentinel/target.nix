{ self, inputs, ... }:
let
  hostName = "sentinel";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hostBase
      user-alexander
      tailscale
      zramCompression
      sentinel
    ];
  };
}
