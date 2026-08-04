{ ... }:
{
  flake.nixosModules.ai = {
    imports = [
      ./preferences.nix
      ./mcp.nix
      ./opencode.nix
    ];
  };
}
