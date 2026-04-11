{ self, inputs, ... }: 
let
  hostName = "nixos";
in
{ 
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      nixos
      locale
      users
      virtualization
      niri
    ];
  };
}
