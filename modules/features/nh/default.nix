{ ... }:
{
  flake.nixosModules.nh =
    {
      config,
      lib,
      ...
    }:
    {
      options.local.nh.osFlake = lib.mkOption {
        type = lib.types.str;
        default = "${config.local.base.homeDirectory}/nixos-configuration";
        description = "Default flake path for nh OS commands.";
      };

      config = {
        programs.nh = {
          enable = true;
          clean.enable = false;
        };

        environment.sessionVariables.NH_OS_FLAKE = config.local.nh.osFlake;
      };
    };
}
