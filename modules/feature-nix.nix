# Nix configuration for all platforms
{ ... }:
let
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
in
{
  flake.modules.nixos.nix =
    { pkgs, ... }:
    {
      nix = {
        enable = true;
        settings = nixSettings;
        optimise.automatic = true;
      };
      nixpkgs.config.allowUnfree = true;
    };

  flake.modules.darwin.nix =
    { pkgs, ... }:
    {
      nix.settings = nixSettings;
      nixpkgs.config.allowUnfree = true;
    };

  flake.modules.homeManager.nix =
    { pkgs, ... }:
    {
      nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
}
