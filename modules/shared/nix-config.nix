# Cross-platform Nix configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Nix configuration with platform awareness
  nix = {
    # Nix daemon is only available on NixOS
    enable = !pkgs.stdenv.isDarwin;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # Automatic optimization only works on NixOS
    optimise.automatic = !pkgs.stdenv.isDarwin;

    # Nix path for flakes
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  # Also ensure nixpkgs config allows unfree packages
  nixpkgs.config.allowUnfree = true;
}
