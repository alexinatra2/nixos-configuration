{ ... }:
{
  flake.darwinModules.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        m-cli
      ];
    };
}
