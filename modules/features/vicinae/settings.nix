{ lib, pkgs }:
let
  format = pkgs.formats.json { };
in
{
  inherit format;

  generate =
    {
      extensionSettings,
      secretImports,
      userSettings,
    }:
    let
      settings = lib.recursiveUpdate {
        keybinding = "emacs";
        providers = extensionSettings;
      } userSettings;
    in
    format.generate "vicinae-settings.json" (
      settings
      // {
        imports = (settings.imports or [ ]) ++ secretImports;
      }
    );
}
