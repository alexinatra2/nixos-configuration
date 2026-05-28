{ inputs, self, ... }:
let
  lib = inputs.nixpkgs.lib;

  mkHost =
    modules:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs self;
      };

      modules = [ ./common ] ++ modules;
    };
in
{
  flake.nixosConfigurations = {
    atlas = mkHost [
      self.nixosModules."user-alexander-profile"
      self.nixosModules.shell
      self.nixosModules.tmuxRemote
      ./atlas
      self.nixosModules.niri
      self.nixosModules.greeter
      self.nixosModules.git
      self.nixosModules.displaylink
      self.nixosModules.gaming
      self.nixosModules.virtualization
      self.nixosModules.fonts
      self.nixosModules.stylix
      self.nixosModules.grub
      self.nixosModules.syncthing
      self.nixosModules.llms
      self.nixosModules.index
      self.nixosModules.tmux
      self.nixosModules.zramCompression
    ];

    sentinel = mkHost [
      self.nixosModules.shell
      self.nixosModules.zramCompression
      ./sentinel
    ];

    warden = mkHost [
      self.nixosModules.prometheus
      self.nixosModules.shell
      self.nixosModules.syncthing
      self.nixosModules.vaultwarden
      ./warden
    ];
  };
}
