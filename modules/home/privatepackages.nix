{ self, inputs, ... }:
{
  flake.modules.homeManager.privatepackages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        eduvpn-client
        qgis
      ];
    };
}
