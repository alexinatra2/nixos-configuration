{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    let
      niriPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    in
    {
      programs.niri = {
        enable = true;
        package = niriPackage;
      };

      services.displayManager.sessionPackages = [ niriPackage ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.myNoctalia)
          ];

          input.keyboard = {
            xkb.layout = "us,de";
          };

          layout.gaps = 5;

          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
            "Mod+Q".close-window = {};
            "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          };
        };
      };
    };
}
