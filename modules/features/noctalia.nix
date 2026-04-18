{ self, inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    if pkgs.stdenv.isLinux then
      {
        packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
          inherit pkgs;
          settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
        };
      }
    else
      { };
}
