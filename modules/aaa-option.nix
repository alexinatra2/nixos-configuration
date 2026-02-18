# Declare the flake.modules option for aspect-oriented organization
{ lib, ... }:
{
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.raw);
    default = { };
    description = "Aspect-oriented modules organized by platform (nixos, darwin, homeManager)";
  };
}
