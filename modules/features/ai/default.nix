{ inputs, ... }:
{
  flake.nixosModules.ai = {
    imports = [
      ./preferences.nix
      ./mcp.nix
      ./glue.nix
    ];
  };
}
