{ self, inputs, ... }:
let
  hostName = "sentinel";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hostBase
      shell
      zramCompression
      sentinel
    ];
  };
}
