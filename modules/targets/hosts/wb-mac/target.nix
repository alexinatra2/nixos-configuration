{ self, inputs, ... }:
let
  hostKey = "wb-mac";
in
{
  flake.darwinConfigurations.${hostKey} = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [ (builtins.getAttr hostKey self.darwinModules) ];
  };
}
