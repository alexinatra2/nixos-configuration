{ self, inputs, ... }:
{
  flake.nixosModules.zramCompression = {
    zramSwap.enable = true;
  };
}
