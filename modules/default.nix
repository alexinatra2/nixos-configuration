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
          if builtins.pathExists (path + "/default.nix") then [ path ] else collectModules path
        else
          [ ]
      ) (builtins.attrNames entries)
    );
in
collectModules ./.
