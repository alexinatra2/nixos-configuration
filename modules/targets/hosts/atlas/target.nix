{ self, inputs, ... }:
let
  hostName = "atlas";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
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
      sops
      tailscale
      syncthing
      llms
      android
      index
      zramCompression
    ];
  };
}
