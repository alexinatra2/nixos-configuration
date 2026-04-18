{ lib, ... }:
{
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "home-manager configurations exported by this flake";
  };
}
