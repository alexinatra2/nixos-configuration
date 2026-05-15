{ self, inputs, ... }:
{
  flake.nixosModules.index = {
    imports = [ inputs.nix-index-database.nixosModules.default ];

    programs.nix-index-database.comma.enable = true;
  };
}
