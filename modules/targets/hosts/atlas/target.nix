{ self, inputs, ... }:
let
  hostName = "atlas";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hostBase
      user-alexander
      atlas
      niri
      greeter
      displaylink
      gaming
      virtualization
      fonts
      stylix
      grub
      tailscale
      syncthing
      llms
      index
      zramCompression
    ];
  };
}
