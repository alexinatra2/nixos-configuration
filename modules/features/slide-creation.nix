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
          marp-cli
          quarto
          pandoc
        ])
        ++ lib.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            onlyoffice-desktopeditors
          ]
        );
    };
}
