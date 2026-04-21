{ self, inputs, ... }:
{
  flake.nixosModules.sops =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = with pkgs; [
        sops
        age
      ];
    };

  flake.modules.homeManager.sops =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.packages = with pkgs; [
        sops
        age
      ];

      sops = {
      };
    };
}
