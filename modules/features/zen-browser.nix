{ self, inputs, ... }:
{
  flake.modules.homeManager.zenBrowser =
    { pkgs, lib, ... }:
    let
      zenPackage =
        if pkgs.stdenv.isLinux then
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        else
          null;
    in
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux [ zenPackage ];
    };

  flake.nixosModules.zenBrowser =
    { pkgs, ... }:
    let
      zenPackage = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      niri.browser = zenPackage;
    };
}
