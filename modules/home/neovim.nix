{ self, inputs, ... }:
{
  flake.modules.homeManager.neovim =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.neovim;
    in
    {
      options.neovim = {
        enable = lib.mkEnableOption "Neovim configuration";
      };

      config = lib.mkIf cfg.enable {
        programs.neovim = {
          enable = true;
          viAlias = true;
          withRuby = false;
          withPython3 = false;
        };
      };
    };
}
