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
  flake.modules.nixos.nix = {
    nix = {
      enable = true;
      settings = nixSettings;
      optimise.automatic = true;
    };
    nixpkgs.config.allowUnfree = true;
  };

  flake.modules.darwin.nix = {
    nix.settings = nixSettings;
    nixpkgs.config.allowUnfree = true;
  };

  flake.modules.homeManager.nix = {
    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
