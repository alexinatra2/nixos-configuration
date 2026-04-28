{ self, inputs, ... }:
let
  hostName = "nixos";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      user-alexander
      nixos
      opencode
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
    ];
  };
}
