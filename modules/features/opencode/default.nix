{ inputs, ... }:
{
  flake.nixosModules.opencode = {
    imports = [
      ./module.nix
    ];
  };
}
