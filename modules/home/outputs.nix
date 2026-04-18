{ lib, ... }:
{
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "home-manager configurations exported by this flake";
  };

  options.flake.wrappersModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "wrapper modules exported by this flake";
  };
}
