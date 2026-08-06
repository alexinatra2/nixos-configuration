{ inputs, ... }:
{
  flake.nixosModules.ai = {
    imports = [
      ./preferences.nix
      ./mcp.nix
      ./opencode.nix
    ];

    _module.args.openviking-nix = inputs.openviking-nix;
  };
}
