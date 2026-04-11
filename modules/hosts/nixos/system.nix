{ self, inputs, ... }: 
let
  hostName = "nixos";
in
{ 
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.${hostName}
    ];
  };
}
