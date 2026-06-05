{ self, inputs, ... }:
{
  flake.nixosModules.work =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        teams-for-linux
      ];
    };
}
