{ self, inputs, ... }:
{
  flake.modules.homeManager.privatepackages =
    { pkgs, lib, ... }:
    {
      # These packages are currently Linux-only in nixpkgs.
      home.packages = lib.optionals pkgs.stdenv.isLinux (
        with pkgs;
        [
          eduvpn-client
          qgis
        ]
      );
    };
}
