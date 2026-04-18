{ self, inputs, ... }:
{
  flake.modules.homeManager.generations =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "/${config.home.homeDirectory}/nixos-configuration";
        clean.enable = true;
      };
    };
}
