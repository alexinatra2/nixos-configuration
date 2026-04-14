{ self, inputs, ... }:
{
  flake.modules.homeManager.obsidian =
    {
      lib,
      options,
      ...
    }:
    let
      hasObsidian = options ? programs.obsidian;
    in
    {
      config = lib.mkIf hasObsidian {
        programs.obsidian = {
          enable = true;
          vaults = {
            "digital-garden" = { };
          };
        };
      };
    };
}
