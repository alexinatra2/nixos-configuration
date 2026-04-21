{ self, inputs, ... }:
let
  hostName = "nixos";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      nixos
      niri
      greeter
      displaylink
      gaming
      virtualization
      fonts
      stylix
      grub
      sops
    ];
  };
}
