{ self, inputs, ... }:
let
  hostName = "atlas";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hostBase
      self.nixosModules."user-alexander-profile"
      shell
      atlas
      niri
      greeter
      git
      displaylink
      gaming
      virtualization
      fonts
      stylix
      grub
      syncthing
      llms
      index
      tmux
      zramCompression
    ];
  };
}
