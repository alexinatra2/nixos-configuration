{ self, inputs, ... }:
{
  flake.modules.homeManager.privatepackages =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux (
        with pkgs;
        [
          eduvpn-client
          qgis
        ]
      );
    };
}
