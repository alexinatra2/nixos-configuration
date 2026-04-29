{ self, inputs, ... }:
{
  flake.modules.homeManager.slide-creation =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages =
        (with pkgs; [
          slidev-cli
        ])
        ++ lib.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            onlyoffice-desktopeditors
          ]
        );
    };
}
