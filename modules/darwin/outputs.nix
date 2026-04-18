{ lib, ... }:
{
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "nix-darwin modules exported by this flake";
  };

  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "nix-darwin system configurations exported by this flake";
  };
}
