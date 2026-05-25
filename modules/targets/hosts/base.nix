{ self, ... }:
{
  flake.nixosModules.hostBase = {
    imports = [ self.nixosModules.sops ];

    sops.defaultSopsFile = ./secrets.yaml;
  };
}
