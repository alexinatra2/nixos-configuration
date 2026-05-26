{ self, inputs, ... }:
let
  hostName = "atlas";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hostBase
      shell
      atlas
      niri
      greeter
      displaylink
      gaming
      virtualization
      fonts
      stylix
      grub
      syncthing
      llms
      index
      zramCompression
    ];
  };
}
