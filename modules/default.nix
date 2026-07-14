{ lib }:

let
  collectModules =
    dir:
    let
      entries = builtins.readDir dir;
    in
    lib.flatten (
      map (
        name:
        let
          path = dir + "/${name}";
          type = entries.${name};
        in
        if type == "directory" then
          collectModules path
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
          [ path ]
        else
          [ ]
      ) (builtins.attrNames entries)
    );
in
collectModules ./.
