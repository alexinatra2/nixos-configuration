{ self, inputs, ... }:
{
  flake.nixosModules.work =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        devenv
        teams-for-linux
      ];
    };
}
