{ self, inputs, ... }:
{
  flake.nixosModules.music =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.ardour
      ];
    };
}
