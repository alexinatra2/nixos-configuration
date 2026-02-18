# Nix configuration for all platforms
{ inputs, ... }:
let
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
in
{
  flake.modules.nixos.nix = {
    nix = {
      enable = true;
      settings = nixSettings;
      optimise.automatic = true;
      nixPath = nixPath;
    };
    nixpkgs.config.allowUnfree = true;
  };

  flake.modules.darwin.nix = {
    nix = {
      enable = false; # Nix daemon not available on Darwin
      settings = nixSettings;
      nixPath = nixPath;
    };
    nixpkgs.config.allowUnfree = true;
  };

  flake.modules.homeManager.nix = {
    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
