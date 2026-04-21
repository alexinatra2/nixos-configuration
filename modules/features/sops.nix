{ self, inputs, ... }:
{
  flake.modules.homeManager.sops =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
    };
}
